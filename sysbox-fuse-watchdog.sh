#!/usr/bin/env bash
# sysbox-fuse-watchdog — сторож клина sysbox-fs (#316, nestybox/sysbox#1018). Раз в минуту по
# cron. Клин: sysbox-fs перестаёт отвечать на запросы FUSE, и любое обращение к /proc внутри
# ЛЮБОЙ песочницы виснет навсегда — движки гаснут по простою, новые песочницы не стартуют,
# а шаги конвейера молчат час до таймаута зомби. Перезапуск sysbox-fs зависшее не освобождает;
# освобождает прерывание соединений FUSE (`abort`) и снятие их контейнеров — конвейер повторяет
# прогоны сам.
#
# Признак клина — ДВА условия сразу, чтобы не принять занятую песочницу за зависшую:
#   1) у соединения sysbox-fs (смонтировано в /var/lib/sysboxfs/<контейнер>) есть ожидающие
#      запросы (`waiting` > 0) WEDGE_MIN минут подряд — по файлу состояния на соединение;
#   2) на машине есть процесс в состоянии D с wchan request_wait_answer старше WEDGE_MIN минут.
# Подтверждённый клин — прерываются ВСЕ соединения sysbox-fs с ожиданием (они все жертвы одной
# блокировки) и снимаются их контейнеры. Соединения не sysbox не трогаются.
set -uo pipefail
WEDGE_MIN="${1:-3}"
CONN="${FUSE_CONNECTIONS:-/sys/fs/fuse/connections}"
MOUNTINFO="${MOUNTINFO:-/proc/self/mountinfo}"
STATE="${STATE_DIR:-/run/sysbox-fuse-watchdog}"
now=$(date +%s)
log() { printf '%s sysbox-fuse-watchdog: %s\n' "$(date -u +%FT%TZ)" "$*"; }
mkdir -p "$STATE"

# minor соединения → контейнер, по монтированиям sysbox-fs
declare -A cid
while read -r dev path; do
  case "$path" in /var/lib/sysboxfs/*) cid["${dev#0:}"]="${path#/var/lib/sysboxfs/}";; esac
done < <(awk '{print $3, $5}' "$MOUNTINFO" 2>/dev/null)

# Состояние по соединениям, которых уже нет: minor переиспользуется — старая отметка не должна
# засчитаться новому соединению.
for f in "$STATE"/*; do
  [ -e "$f" ] || continue
  [ -d "$CONN/$(basename "$f")" ] || rm -f "$f"
done

waiting=() # соединения sysbox-fs с ожидающими запросами сейчас
stuck=()   # из них — дольше порога
for d in "$CONN"/*; do
  [ -d "$d" ] || continue
  m=$(basename "$d")
  [ -n "${cid[$m]:-}" ] || continue
  w=$(cat "$d/waiting" 2>/dev/null || echo 0)
  if [ "${w:-0}" -gt 0 ]; then
    waiting+=("$m")
    [ -f "$STATE/$m" ] || echo "$now" > "$STATE/$m"
    since=$(cat "$STATE/$m")
    [ $(( (now - since) / 60 )) -ge "$WEDGE_MIN" ] && stuck+=("$m")
  else
    rm -f "$STATE/$m"
  fi
done
[ ${#stuck[@]} -gt 0 ] || exit 0

hung=$(ps -eo stat,etimes,wchan:32 2>/dev/null | awk -v s=$((WEDGE_MIN * 60)) '$1 ~ /^D/ && $3 == "request_wait_answer" && $2 >= s' | wc -l)
[ "$hung" -gt 0 ] || exit 0

log "клин sysbox-fs: соединений с ожиданием ${#waiting[@]} (дольше ${WEDGE_MIN} мин: ${#stuck[@]}), процессов в D: ${hung} — прерываю"
for m in "${waiting[@]}"; do
  echo 1 > "$CONN/$m/abort" 2>/dev/null && log "прервано соединение $m (контейнер ${cid[$m]:0:12})"
  rm -f "$STATE/$m"
done
for m in "${waiting[@]}"; do
  c="${cid[$m]}"
  docker rm -f "$c" >/dev/null 2>&1 && log "снят контейнер ${c:0:12}"
done
log "готово"
