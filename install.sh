#!/usr/bin/env bash
# Buff Community Edition — установка на чистый хост (#605, #606; эпик #600).
#
# Что делает (идемпотентно, повтор — норма):
#   1. Docker Engine из официального репозитория Docker (если его нет).
#   2. Sysbox CE закреплённой версии: среда выполнения, в которой наш контейнер получает
#      СВОЙ dockerd для раннеров инструментов разработки — без privileged и без сокета хоста.
#   3. daemon.json: runtime sysbox-runc, live-restore, выключенные time-namespaces (Docker ≥ 29
#      даёт каждому контейнеру своё пространство времени, Sysbox 0.7 его не знает), запас сетей.
#   4. Сторож клина sysbox-fs раз в минуту (cron).
#   5. Текущего пользователя — в группу docker.
#   6. Если рядом лежит docker-compose.yml — `docker compose pull && up -d`.
#
# Запуск: обычным пользователем с sudo (не под root):  ./install.sh
# Требования: Ubuntu 22.04/24.04 (amd64), ядро ≥ 5.7, выделенная ВМ (не Docker Desktop).
set -euo pipefail

SYSBOX_VERSION="${SYSBOX_VERSION:-0.7.1}"
SYSBOX_SHA256="${SYSBOX_SHA256:-9d6d5484f980d0a17f86c492c1262015c2afb66280bdb97215b79fde6a0261c5}"
SANDBOX_POOL="${SANDBOX_POOL:-10.200.0.0/16}"
WEDGE_MINUTES="${WEDGE_MINUTES:-3}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { printf '\033[1m[buff]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[buff]\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "запускайте обычным пользователем с sudo, не под root"
sudo -n true 2>/dev/null || die "нужен sudo без пароля для этого пользователя (или введите пароль: sudo -v) и повторите"
[ "$(uname -m)" = "x86_64" ] || die "поддерживается только amd64 (x86_64)"
. /etc/os-release
[ "${ID:-}" = "ubuntu" ] && [[ "${VERSION_ID:-}" =~ ^(22|24)\.04$ ]] || die "поддерживается Ubuntu 22.04 / 24.04, здесь: ${PRETTY_NAME:-?}"
kver="$(uname -r | cut -d- -f1)"
[ "$(printf '%s\n5.7\n' "$kver" | sort -V | head -1)" = "5.7" ] || die "ядро $kver старше 5.7 — Sysbox нужен seccomp notify"

export DEBIAN_FRONTEND=noninteractive
APT="sudo -E apt-get -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20 -o Acquire::Retries=1"

# ---- 1. Docker Engine -----------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  say "ставлю Docker Engine (официальный репозиторий Docker)"
  $APT -qq update
  $APT -qq install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  $APT -qq update
  $APT -qq install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
  say "Docker уже есть: $(docker --version)"
fi
docker compose version >/dev/null 2>&1 || { say "ставлю docker compose plugin"; $APT -qq update; $APT -qq install -y docker-compose-plugin; }

# ---- 2. Sysbox ------------------------------------------------------------------------------
installed="$(dpkg-query -W -f='${Version}' sysbox-ce 2>/dev/null || true)"
if [[ "$installed" != "$SYSBOX_VERSION"* ]]; then
  say "ставлю Sysbox CE $SYSBOX_VERSION (сейчас: ${installed:-нет})"
  $APT -qq update || true
  $APT -qq install -y jq fuse3 cron
  deb="/tmp/sysbox-ce_${SYSBOX_VERSION}.deb"
  curl -fsSL -o "$deb" "https://downloads.nestybox.com/sysbox/releases/v${SYSBOX_VERSION}/sysbox-ce_${SYSBOX_VERSION}-0.linux_amd64.deb"
  echo "${SYSBOX_SHA256}  ${deb}" | sha256sum -c - >/dev/null || die "контрольная сумма пакета Sysbox не сошлась"
  # Песочницы старой версии не переживут обновление sysbox-fs/sysbox-mgr — снять заранее.
  ids="$(sudo docker ps -q 2>/dev/null | xargs -r sudo docker inspect 2>/dev/null | jq -r '.[] | select(.HostConfig.Runtime == "sysbox-runc") | .Id' || true)"
  [ -z "$ids" ] || sudo docker rm -f $ids >/dev/null
  $APT -qq install -y "$deb"
else
  say "Sysbox $installed уже стоит"
fi
sudo systemctl enable --now sysbox >/dev/null 2>&1 || true

# ---- 3. daemon.json -------------------------------------------------------------------------
f=/etc/docker/daemon.json
sudo test -s "$f" || echo '{}' | sudo tee "$f" >/dev/null
want="$(sudo jq -S --arg pool "$SANDBOX_POOL" '
  .["live-restore"] = true
  | .features = ((.features // {}) + {"time-namespaces": false})
  | .runtimes = ((.runtimes // {}) + {"sysbox-runc": {"path": "/usr/bin/sysbox-runc"}})
  | .["default-address-pools"] = ((.["default-address-pools"] // [])
      | if any(.[]; .base == $pool) then . else . + [{"base": $pool, "size": 24}] end)' "$f")"
if [ "$want" != "$(sudo jq -S . "$f")" ]; then
  say "обновляю $f (live-restore, без time-namespaces, runtime sysbox-runc, пул сетей)"
  printf '%s\n' "$want" | sudo tee "$f.new" >/dev/null && sudo mv "$f.new" "$f"
  sudo systemctl reload docker   # live-restore подхватывается по SIGHUP…
  sudo systemctl restart docker  # …и тогда перезапуск применяет features, не трогая контейнеры
fi

# ---- 4. Сторож клина sysbox-fs ---------------------------------------------------------------
command -v crontab >/dev/null 2>&1 || { $APT -qq update || true; $APT -qq install -y cron; }
sudo systemctl enable --now cron >/dev/null 2>&1 || true
sudo install -m 0755 "$HERE/sysbox-fuse-watchdog.sh" /usr/local/sbin/sysbox-fuse-watchdog
line="* * * * * /bin/bash /usr/local/sbin/sysbox-fuse-watchdog ${WEDGE_MINUTES} >> /var/log/sysbox-fuse-watchdog.log 2>&1"
{ sudo crontab -l 2>/dev/null | grep -v sysbox-fuse-watchdog || true; echo "$line"; } | sudo crontab -

# ---- 5. Пользователь в docker ---------------------------------------------------------------
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  sudo usermod -aG docker "$USER"
  say "добавил $USER в группу docker — текущая сессия ещё без неё, ниже команды идут через sudo"
fi
D="sudo docker"

# ---- Проверка: песочница поднимается ---------------------------------------------------------
say "проверяю Sysbox живым контейнером"
$D run --rm --runtime=sysbox-runc alpine:3.20 true >/dev/null && say "Sysbox работает"

# ---- 6. Настройки установки (.env) -----------------------------------------------------------
# Первый запуск: .env из .env.example, пароли служб и первого администратора — случайные,
# адрес приложения — по адресу этой машины. Повтор .env не трогает.
if [ -f "$HERE/docker-compose.yml" ] && [ ! -f "$HERE/.env" ]; then
  say "создаю .env"
  rand() { head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c "$1"; }
  ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)"
  cp "$HERE/.env.example" "$HERE/.env"
  put() { sed -i "s#^$1=.*#$1=$2#" "$HERE/.env"; }
  put APP_URL "http://${ip:-127.0.0.1}:8138"
  put ADMIN_EMAIL "admin@${ip:-localhost}"
  put ADMIN_PASSWORD "$(rand 20)"
  put PG_PASSWORD "$(rand 32)"
  put GITEA_ADMIN_PASSWORD "$(rand 24)"
  put WM_ADMIN_PASSWORD "$(rand 24)"
  chmod 600 "$HERE/.env"
  say "пароли записаны в $HERE/.env (пароль администратора — ADMIN_PASSWORD); впишите ORG, LLM_* и при необходимости APP_URL"
fi

# ---- 7. Сборка -------------------------------------------------------------------------------
if [ -f "$HERE/docker-compose.yml" ]; then
  say "поднимаю сборку: docker compose up -d"
  (cd "$HERE" && $D compose up -d)
  say "готово — приложение: $(grep ^APP_URL= "$HERE/.env" | cut -d= -f2-), админка — порт 8150; первый старт занимает несколько минут: docker compose logs -f buff"
else
  say "docker-compose.yml рядом нет — хост подготовлен, сборка поднимается отдельно"
fi
