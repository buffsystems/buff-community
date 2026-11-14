#!/usr/bin/env bash
# Pure helpers of install.sh (#886), tested without running the installer: each function is taken from
# the script by name and run in a temp dir. Run: bash test/install.test.sh
set -euo pipefail
HERE_TEST="$(cd "$(dirname "$0")/.." && pwd)"
fn() { sed -n "/^$1() {/,/^}/p" "$HERE_TEST/install.sh"; }
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok - $1"; else echo "not ok - $1: got «$2», want «$3»"; fail=1; fi; }

eval "$(fn runners_for)"
check "runners: unknown memory → 3" "$(runners_for 0)" 3
check "runners: 8 GB available → 3" "$(runners_for 8192)" 3
check "runners: never above 15" "$(runners_for 64000)" 15

eval "$(fn available_mb)"
check "available memory: MemAvailable of /proc/meminfo, in MB" "$(MEMINFO=<(printf 'MemTotal: 32000000 kB\nMemAvailable: 8388608 kB\n') available_mb)" 8192

T="$(mktemp -d)"; HERE="$T"
printf 'APP_URL=http://127.0.0.1:8138\nBIND_IP=0.0.0.0\nAPP_PORT=8138\nADMIN_PORT=8150\nRUNNERS=3\n' > "$T/.env"
put() { sed -i.bak "s#^$1=.*#$1=$2#" "$HERE/.env" && rm -f "$HERE/.env.bak"; }
eval "$(fn env_overrides)"
APP_PORT=9138 ADMIN_PORT=9150 BIND_IP=127.0.0.1 env_overrides
check "ports and address from the environment reach .env" "$(grep -E '^(APP_PORT|ADMIN_PORT|BIND_IP)=' "$T/.env" | tr '\n' ' ')" "BIND_IP=127.0.0.1 APP_PORT=9138 ADMIN_PORT=9150 "
check "the app address follows the port" "$(grep '^APP_URL=' "$T/.env")" "APP_URL=http://127.0.0.1:9138"
rm -rf "$T"
exit $fail
