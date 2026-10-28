#!/usr/bin/env bash
# Buff Community Edition — установка (#605, #606, #621; эпик #600).
#
# Два режима, выбирается сам:
#   Linux (Ubuntu 22.04/24.04, amd64): Docker Engine + Sysbox — наш контейнер получает СВОЙ
#     dockerd для раннеров и песочниц без privileged и без сокета хоста.
#   Docker Desktop (macOS, Windows через Git Bash, Linux с Docker Desktop): Sysbox нет,
#     контейнер запускается привилегированным (docker-compose.desktop.yml).
#
# Что делает (идемпотентно, повтор — норма):
#   Linux: 1. Docker Engine; 2. Sysbox CE закреплённой версии; 3. daemon.json (runtime sysbox-runc,
#   live-restore, без time-namespaces, запас сетей); 4. сторож клина sysbox-fs (cron);
#   5. текущего пользователя — в группу docker.
#   Оба: 6. образ выпуска — с GitHub (ghcr.io) или из файла в images/ (закрытый контур);
#   7. .env со случайными паролями; 8. docker compose up -d и ход первого старта в терминале.
#
# Запуск: обычным пользователем (на Linux — с sudo, не под root):  ./install.sh
set -euo pipefail

SYSBOX_VERSION="${SYSBOX_VERSION:-0.7.1}"
SYSBOX_SHA256="${SYSBOX_SHA256:-9d6d5484f980d0a17f86c492c1262015c2afb66280bdb97215b79fde6a0261c5}"
SANDBOX_POOL="${SANDBOX_POOL:-10.200.0.0/16}"
WEDGE_MINUTES="${WEDGE_MINUTES:-3}"
BOOT_TIMEOUT="${BOOT_TIMEOUT:-2400}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The language the installer speaks (#717, epic #565): --lang en|ru or BUFF_LANG, else the
# system's first Russian or English language (LANGUAGE, LC_ALL, LC_MESSAGES, LANG), else
# Russian. Every message is written in both: say "русский" "English".
INSTALL_LANG="${BUFF_LANG:-}"
for a in "$@"; do case "$a" in --lang=*) INSTALL_LANG="${a#--lang=}" ;; esac; done
if [ "$INSTALL_LANG" != en ] && [ "$INSTALL_LANG" != ru ]; then
  INSTALL_LANG=ru
  langs="${LANGUAGE:-}"
  for tag in ${langs//:/ } ${LC_ALL:-} ${LC_MESSAGES:-} ${LANG:-}; do
    case "${tag%%[_.@-]*}" in ru) break ;; en) INSTALL_LANG=en; break ;; esac
  done
fi
pick() { if [ "$INSTALL_LANG" = en ] && [ -n "${2:-}" ]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }
say() { printf '\033[1m[buff]\033[0m %s\n' "$(pick "$@")"; }
die() { printf '\033[1;31m[buff]\033[0m %s\n' "$(pick "$@")" >&2; exit 1; }

# ---- режим ----------------------------------------------------------------------------------
MODE=linux
case "$(uname -s)" in Darwin | MINGW* | MSYS* | CYGWIN*) MODE=desktop ;; esac
if [ "$MODE" = linux ] && command -v docker >/dev/null 2>&1 && docker info 2>/dev/null | grep -q "Docker Desktop"; then MODE=desktop; fi
# BUFF_MODE=desktop — принудительно режим Docker Desktop (например, Linux без Sysbox).
MODE="${BUFF_MODE:-$MODE}"
[ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ] || die "поддерживаются amd64 и arm64, здесь: $(uname -m)" "amd64 and arm64 are supported, this is: $(uname -m)"

if [ "$MODE" = desktop ]; then
  say "режим Docker Desktop: без Sysbox, контейнер работает привилегированным" "Docker Desktop mode: no Sysbox, the container runs privileged"
  command -v docker >/dev/null 2>&1 || die "нужен Docker Desktop: https://docs.docker.com/desktop/ — поставьте, запустите и повторите" "Docker Desktop is needed: https://docs.docker.com/desktop/ — install it, start it and run this again"
  docker info >/dev/null 2>&1 || die "Docker Desktop не отвечает — запустите его и повторите" "Docker Desktop does not answer — start it and run this again"
  docker compose version >/dev/null 2>&1 || die "в Docker Desktop нет docker compose — обновите Docker Desktop" "Docker Desktop has no docker compose — update Docker Desktop"
  [ "$(uname -m)" = "x86_64" ] || say "внимание: образ собран для amd64 — на arm64 (Apple Silicon) он идёт через эмуляцию, медленно" "note: the image is built for amd64 — on arm64 (Apple Silicon) it runs under emulation, slowly"
  D="docker"
else
  [ "$(id -u)" -ne 0 ] || die "запускайте обычным пользователем с sudo, не под root" "run as a regular user with sudo, not as root"
  sudo -n true 2>/dev/null || die "нужен sudo без пароля для этого пользователя (или введите пароль: sudo -v) и повторите" "this user needs sudo without a password (or enter it: sudo -v) — then run this again"
  [ "$(uname -m)" = "x86_64" ] || die "на Linux поддерживается только amd64 (x86_64)" "on Linux only amd64 (x86_64) is supported"
  . /etc/os-release
  [ "${ID:-}" = "ubuntu" ] && [[ "${VERSION_ID:-}" =~ ^(22|24)\.04$ ]] || die "поддерживается Ubuntu 22.04 / 24.04, здесь: ${PRETTY_NAME:-?}" "Ubuntu 22.04 / 24.04 is supported, this is: ${PRETTY_NAME:-?}"
  kver="$(uname -r | cut -d- -f1)"
  [ "$(printf '%s\n5.7\n' "$kver" | sort -V | head -1)" = "5.7" ] || die "ядро $kver старше 5.7 — Sysbox нужен seccomp notify" "kernel $kver is older than 5.7 — Sysbox needs seccomp notify"
  export DEBIAN_FRONTEND=noninteractive
  APT="sudo -E apt-get -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20 -o Acquire::Retries=1"
  D="sudo docker"
fi

if [ "$MODE" = linux ]; then
  # needrestart на Ubuntu 24.04 после обновления пакетов (и автообновлений свежей машины) сам
  # перезапускает службы, в том числе sysbox: у работающего контейнера отваливается /proc, и
  # docker exec в него больше не проходит. Пусть только сообщает — как на машинах SaaS (#424).
  if [ -d /etc/needrestart ]; then
    sudo install -d -m 0755 /etc/needrestart/conf.d
    echo "\$nrconf{restart} = 'l';" | sudo tee /etc/needrestart/conf.d/buff-install.conf >/dev/null
  fi

  # ---- 1. Docker Engine -----------------------------------------------------------------------
  if ! command -v docker >/dev/null 2>&1; then
    say "ставлю Docker Engine (официальный репозиторий Docker)" "installing Docker Engine (Docker's official repository)"
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
    say "Docker уже есть: $(docker --version)" "Docker is already here: $(docker --version)"
  fi
  docker compose version >/dev/null 2>&1 || { say "ставлю docker compose plugin" "installing the docker compose plugin"; $APT -qq update; $APT -qq install -y docker-compose-plugin; }

  # ---- 2. Sysbox ------------------------------------------------------------------------------
  installed="$(dpkg-query -W -f='${Version}' sysbox-ce 2>/dev/null || true)"
  if [[ "$installed" != "$SYSBOX_VERSION"* ]]; then
    say "ставлю Sysbox CE $SYSBOX_VERSION (сейчас: ${installed:-нет})" "installing Sysbox CE $SYSBOX_VERSION (now: ${installed:-none})"
    $APT -qq update || true
    $APT -qq install -y jq fuse3 cron
    deb="/tmp/sysbox-ce_${SYSBOX_VERSION}.deb"
    curl -fsSL -o "$deb" "https://downloads.nestybox.com/sysbox/releases/v${SYSBOX_VERSION}/sysbox-ce_${SYSBOX_VERSION}-0.linux_amd64.deb"
    echo "${SYSBOX_SHA256}  ${deb}" | sha256sum -c - >/dev/null || die "контрольная сумма пакета Sysbox не сошлась" "the Sysbox package checksum does not match"
    # Песочницы старой версии не переживут обновление sysbox-fs/sysbox-mgr — снять заранее.
    ids="$(sudo docker ps -q 2>/dev/null | xargs -r sudo docker inspect 2>/dev/null | jq -r '.[] | select(.HostConfig.Runtime == "sysbox-runc") | .Id' || true)"
    [ -z "$ids" ] || sudo docker rm -f $ids >/dev/null
    $APT -qq install -y "$deb"
  else
    say "Sysbox $installed уже стоит" "Sysbox $installed is already installed"
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
    say "обновляю $f (live-restore, без time-namespaces, runtime sysbox-runc, пул сетей)" "updating $f (live-restore, no time namespaces, sysbox-runc runtime, network pool)"
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
    say "добавил $USER в группу docker — текущая сессия ещё без неё, ниже команды идут через sudo" "added $USER to the docker group — this session does not have it yet, so the commands below use sudo"
  fi

  say "проверяю Sysbox живым контейнером" "checking Sysbox with a live container"
  $D run --rm --runtime=sysbox-runc alpine:3.20 true >/dev/null && say "Sysbox работает" "Sysbox works"
fi

# ---- 6. Образ установки (#619) -------------------------------------------------------------
# Образ выпуска лежит на GitHub (ghcr.io) — docker pull показывает ход скачивания сам.
# Закрытый контур: файл образа и его .sha256 в images/ (перенесены носителем) загружаются
# вместо скачивания.
sha256_check() { if command -v sha256sum >/dev/null 2>&1; then sha256sum -c --quiet "$1"; else shasum -a 256 -c --quiet "$1"; fi; }
fetch_image() {
  local image="$1" dir="$HERE/images" file="buff-community.tar.zst"
  if $D image inspect "$image" >/dev/null 2>&1; then say "образ $image уже в docker" "image $image is already in docker"; return 0; fi
  mkdir -p "$dir"
  if [ -s "$dir/$file" ] && [ -s "$dir/$file.sha256" ]; then
    command -v zstd >/dev/null 2>&1 || { [ "$MODE" = linux ] || die "для файла образа нужен zstd (brew install zstd)" "an image file needs zstd (brew install zstd)"; say "ставлю zstd" "installing zstd"; $APT -qq install -y zstd; }
    (cd "$dir" && sha256_check "$file.sha256") || die "образ в $dir не сходится с контрольной суммой" "the image in $dir does not match its checksum"
    say "загружаю образ из $dir/$file" "loading the image from $dir/$file"
    zstd -dc "$dir/$file" | $D load >/dev/null
  else
    say "скачиваю образ $image (несколько гигабайт — ход ниже)" "downloading image $image (several gigabytes — progress below)"
    $D pull "$image" || die "образ $image не скачался — проверьте BUFF_IMAGE и доступ к ghcr.io" "image $image did not download — check BUFF_IMAGE and access to ghcr.io"
  fi
  $D image inspect "$image" >/dev/null 2>&1 || die "после загрузки образа $image в docker нет — проверьте BUFF_IMAGE" "after loading, image $image is not in docker — check BUFF_IMAGE"
}

# ---- 6a. Образ песочницы агента (#620) -----------------------------------------------------------
# Собирается здесь, на вашей машине, поверх стокового образа Windmill (sandbox/Dockerfile) — мы
# его не распространяем. Закрытый контур: файл buff-community-sandbox.tar.zst в images/.
build_sandbox() {
  local image="$1" base="$2" windmill="$3" dir="$HERE/images" file="buff-community-sandbox.tar.zst"
  if $D image inspect "$image" >/dev/null 2>&1; then say "образ песочницы $image уже в docker" "sandbox image $image is already in docker"; return 0; fi
  if [ -s "$dir/$file" ] && [ -s "$dir/$file.sha256" ]; then
    (cd "$dir" && sha256_check "$file.sha256") || die "образ песочницы в $dir не сходится с контрольной суммой" "the sandbox image in $dir does not match its checksum"
    say "загружаю образ песочницы из $dir/$file" "loading the sandbox image from $dir/$file"
    zstd -dc "$dir/$file" | $D load >/dev/null
  else
    say "собираю образ песочницы $image поверх Windmill (несколько минут — ход ниже)" "building sandbox image $image on top of Windmill (a few minutes — progress below)"
    $D build -t "$image" --build-arg "BUFF_IMAGE=$base" --build-arg "WINDMILL_IMAGE=$windmill" "$HERE/sandbox" || die "образ песочницы не собрался — смотрите вывод выше" "the sandbox image did not build — see the output above"
  fi
  $D image inspect "$image" >/dev/null 2>&1 || die "образа песочницы $image в docker нет" "sandbox image $image is not in docker"
}
# Во внутренний docker нашего контейнера образ едет с хоста (docker save | load) — без второго скачивания.
handover_sandbox() {
  local image="$1" cid="$2"
  if $D exec "$cid" /opt/docker-real/docker image inspect "$image" >/dev/null 2>&1; then return 0; fi
  say "передаю образ песочницы во внутренний docker (несколько минут)" "handing the sandbox image to the inner docker (a few minutes)"
  $D save "$image" | $D exec -i "$cid" /opt/docker-real/docker load >/dev/null || die "образ песочницы не передался во внутренний docker — повторите ./install.sh" "the sandbox image did not reach the inner docker — run ./install.sh again"
  say "образ песочницы на месте" "the sandbox image is in place"
}

# ---- 7. Настройки установки (.env) -----------------------------------------------------------
# Первый запуск: .env из .env.example, пароли служб и первого администратора — случайные,
# адрес приложения — по адресу этой машины. Повтор .env не трогает.
if [ -f "$HERE/docker-compose.yml" ] && [ ! -f "$HERE/.env" ]; then
  say "создаю .env" "creating .env"
  rand() { head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c "$1"; }
  ip=""
  if [ "$MODE" = linux ]; then ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)"; fi
  cp "$HERE/.env.example" "$HERE/.env"
  put() { sed -i.bak "s#^$1=.*#$1=$2#" "$HERE/.env" && rm -f "$HERE/.env.bak"; }
  put APP_URL "http://${ip:-127.0.0.1}:8138"
  put BUFF_LANG "$INSTALL_LANG"
  # Почта администратора нужна внутреннему git-серверу настоящей: «admin@localhost» он отвергает.
  [ -z "$ip" ] || put ADMIN_EMAIL "admin@${ip}"
  put ADMIN_PASSWORD "$(rand 20)"
  put PG_PASSWORD "$(rand 32)"
  put GITEA_ADMIN_PASSWORD "$(rand 24)"
  put WM_ADMIN_PASSWORD "$(rand 24)"
  if [ "$MODE" = desktop ]; then sed -i.bak 's#^\# COMPOSE_FILE=#COMPOSE_FILE=#' "$HERE/.env" && rm -f "$HERE/.env.bak"; fi
  # Своё — спрашиваем здесь, пока сборка не поднята: переменная окружения (ORG=acme ./install.sh)
  # имеет приоритет, в терминале — вопрос с умолчанием, без терминала — умолчание из .env.example.
  ask() { # переменная, подсказка по-русски, по-английски, [silent]
    local var="$1" prompt cur val
    prompt="$(pick "$2" "$3")"
    cur="$(grep "^$var=" "$HERE/.env" | head -1 | cut -d= -f2-)"
    if [ -n "${!var:-}" ]; then val="${!var}"
    elif [ -t 0 ]; then
      if [ "${4:-}" = silent ]; then read -r -s -p "$prompt: " val; echo; else read -r -p "$prompt [${cur:-$(pick пусто empty)}]: " val; fi
    fi
    [ -z "${val:-}" ] || put "$var" "$val"
  }
  say "настройки установки (Enter — оставить как есть, поправить можно потом в .env)" "installation settings (Enter keeps the value; you can change them later in .env)"
  ask ORG "имя вашей организации латиницей" "your organisation's name in Latin letters"
  ask ADMIN_EMAIL "почта администратора" "the administrator's email"
  ask LLM_BASE_URL "адрес OpenAI-совместимого эндпоинта модели" "the address of the model's OpenAI-compatible endpoint"
  ask LLM_API_KEY "ключ эндпоинта (ввод скрыт)" "the endpoint key (hidden input)" silent
  ask LLM_MODEL "модель, например openai/gpt-4.1" "the model, for example openai/gpt-4.1"
  chmod 600 "$HERE/.env"
  say "пароли записаны в $HERE/.env (пароль администратора — ADMIN_PASSWORD)" "passwords are written to $HERE/.env (the administrator password is ADMIN_PASSWORD)"
fi

# ---- 8. Сборка и первый старт ----------------------------------------------------------------
# Ход первого старта виден здесь: строки «[bootstrap]» нашего контейнера до «готово». Повторный
# запуск уже работающей сборки ничего не ждёт.
follow_bootstrap() {
  local since="$1" cid="$2" started log lp n seen=0 state
  started=$(date +%s); log="$(mktemp)"
  $D compose logs -f --no-log-prefix --since "$since" buff >"$log" 2>&1 &
  lp=$!
  while kill -0 "$lp" 2>/dev/null; do
    n=$(grep -c '\[bootstrap\]' "$log" 2>/dev/null || true); n=${n:-0}
    if [ "$n" -gt "$seen" ]; then
      grep '\[bootstrap\]' "$log" | sed -n "$((seen + 1)),${n}p" | sed "s/.*\[bootstrap\]$(printf '\033')\[0m //; s/.*\[bootstrap\] //" \
        | while IFS= read -r l; do printf '  %4ds  %s\n' "$(($(date +%s) - started))" "$l"; done
      seen=$n
    fi
    if grep -qE 'готово:|ready:' "$log"; then kill "$lp" 2>/dev/null; rm -f "$log"; return 0; fi
    state="$($D inspect -f '{{.State.Status}}' "$cid" 2>/dev/null || true)"
    if [ -n "$state" ] && [ "$state" != "running" ]; then
      kill "$lp" 2>/dev/null; tail -n 20 "$log" >&2; rm -f "$log"
      die "контейнер buff остановился (состояние: $state) — выше последние строки его журнала; полный: docker compose logs buff" "the buff container stopped (state: $state) — its last log lines are above; the full log: docker compose logs buff"
    fi
    # Первый старт — программа bootstrap под супервизором: её выход без «готово» — провал.
    if $D exec "$cid" supervisorctl status bootstrap 2>/dev/null | grep -qE 'EXITED|FATAL'; then
      kill "$lp" 2>/dev/null
      grep '\[bootstrap\]' "$log" | tail -n 5 | sed "s/.*\[bootstrap\]$(printf '\033')\[0m //; s/.*\[bootstrap\] //" >&2
      rm -f "$log"
      die "первый старт прервался — выше его последние строки; полный журнал: docker compose logs buff" "the first start was interrupted — its last lines are above; the full log: docker compose logs buff"
    fi
    if [ $(($(date +%s) - started)) -ge "$BOOT_TIMEOUT" ]; then
      kill "$lp" 2>/dev/null; rm -f "$log"
      die "первый старт не завершился за $((BOOT_TIMEOUT / 60)) минут — смотрите docker compose logs buff" "the first start did not finish in $((BOOT_TIMEOUT / 60)) minutes — see docker compose logs buff"
    fi
    sleep 3
  done
  rm -f "$log"
  die "журнал контейнера buff прервался — смотрите docker compose logs buff" "the buff container log broke off — see docker compose logs buff"
}

if [ -f "$HERE/docker-compose.yml" ]; then
  envget() { grep "^$1=" "$HERE/.env" | head -1 | cut -d= -f2-; }
  fetch_image "$(envget BUFF_IMAGE)"
  sandbox="$(envget SANDBOX_IMAGE)"; sandbox="${sandbox:-buff-community-sandbox:local}"
  build_sandbox "$sandbox" "$(envget BUFF_IMAGE)" "$(envget WINDMILL_IMAGE)"
  cd "$HERE"
  before="$($D compose ps -q buff 2>/dev/null || true)"
  since="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  say "поднимаю сборку: docker compose up -d" "starting the stack: docker compose up -d"
  $D compose up -d
  after="$($D compose ps -q buff 2>/dev/null || true)"
  if [ -n "$before" ] && [ "$before" = "$after" ]; then
    say "сборка уже работала — приложение: $(envget APP_URL), админка — порт $(envget ADMIN_PORT)" "the stack was already running — the app: $(envget APP_URL), the admin panel: port $(envget ADMIN_PORT)"
    handover_sandbox "$sandbox" "$after"
  else
    say "первый старт: базы, учётные записи, выкладка пайплайна — несколько минут" "first start: databases, accounts, deploying the pipeline — a few minutes"
    follow_bootstrap "$since" "$after"
    handover_sandbox "$sandbox" "$after"
    say "готово — приложение: $(envget APP_URL), админка: порт $(envget ADMIN_PORT) (пользователь admin, пароль ADMIN_PASSWORD из .env)" "done — the app: $(envget APP_URL), the admin panel: port $(envget ADMIN_PORT) (user admin, password ADMIN_PASSWORD from .env)"
  fi
else
  say "docker-compose.yml рядом нет — хост подготовлен, сборка поднимается отдельно" "no docker-compose.yml here — the host is prepared, the stack is started separately"
fi
