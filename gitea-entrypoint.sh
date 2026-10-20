#!/bin/sh
# Gitea в сборке Community (#606): стоковый образ, поверх — первый старт. Пока сервер
# поднимается, создаём администратора установки и выпускаем два токена (полный и только
# чтение) в общий том /buff-tokens — их читает наш контейнер. Повтор — ничего не делает.
set -eu
/usr/bin/entrypoint /usr/bin/s6-svscan /etc/s6 &
PID=$!
ADMIN="${GITEA_ADMIN_USER:-wmadmin}"
i=0
until wget -q -O- http://127.0.0.1:3000/api/healthz >/dev/null 2>&1; do
  i=$((i + 1)); [ "$i" -le 120 ] || { echo "gitea не поднялась за 4 минуты" >&2; exit 1; }
  sleep 2
done
if ! su git -c "gitea admin user list --admin" | awk 'NR>1 {print $2}' | grep -qx "$ADMIN"; then
  su git -c "gitea admin user create --admin --username '$ADMIN' --email 'admin@buff.local' --password '$GITEA_ADMIN_PASSWORD' --must-change-password=false"
fi
mkdir -p /buff-tokens
issue() { # файл, области
  [ -s "/buff-tokens/$1" ] && return 0
  su git -c "gitea admin user generate-access-token --username '$ADMIN' --token-name '${1%.token}-$(date +%s)' --scopes '$2' --raw" > "/buff-tokens/$1.tmp"
  mv "/buff-tokens/$1.tmp" "/buff-tokens/$1"
  chmod 600 "/buff-tokens/$1"
}
issue gitea-admin.token all
issue gitea-read.token read:organization,read:repository,read:issue,read:user
echo "gitea: администратор и токены готовы"
wait $PID
