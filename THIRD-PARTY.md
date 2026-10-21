# Сторонние компоненты Buff Community Edition

Что входит в сборку или устанавливается рядом с ней, под какой лицензией и что это обязывает. Ревизия от 20 октября 2026 года (задача #604 эпика #600); обновляется с каждым выпуском.

## Компоненты, которые сборка НЕ включает, а `docker compose` загружает из источников авторов

| Компонент | Источник | Лицензия | Примечание |
|---|---|---|---|
| Windmill (Community Edition) | `ghcr.io/windmill-labs/windmill` (образ закреплён по digest) | AGPLv3 для открытой части; образ содержит проприетарный код Windmill Labs | Мы Windmill **не распространяем и не изменяем**: compose ссылается на образ авторов, вы загружаете его сами на их условиях. Наши флоу общаются с Windmill через его API как отдельная программа. |
| PostgreSQL | `postgres` | PostgreSQL License | |
| Gitea | `gitea/gitea` | MIT | Внутреннее git-хранилище сборки, пользователю не виден. |

## Компоненты внутри нашего образа

| Компонент | Лицензия | Обязательство |
|---|---|---|
| NATS Server, nats (JS), nats.ws | Apache-2.0 | уведомление ниже |
| Apache Tika | Apache-2.0 | уведомление ниже |
| Buff Code — форк [opencode](https://github.com/anomalyco/opencode) | MIT | текст лицензии и копирайт сохранены в сборке |
| Node.js, Bun | MIT | |
| Python 3, psycopg 3 | PSF-2.0; LGPL-3.0 (psycopg) | psycopg используется как заменяемая библиотека (импорт модуля), без изменений |
| cryptography (Python) | Apache-2.0 / BSD-3-Clause | |
| web-push (Node) | MPL-2.0 | используется без изменений; исходники файлов под MPL доступны у авторов и по запросу |
| React, Vite, Express, lucide, Radix UI, Tailwind и прочие npm-зависимости | MIT, ISC, Apache-2.0, BSD-2/3-Clause, 0BSD, BlueOak-1.0.0 | полный перечень с версиями — `THIRD-PARTY-npm.txt` в каждом выпуске |

Проверка зависимостей npm (frontend, admin, middleware, auth-worker, ui, common-lib) от 20.10.2026: GPL/AGPL/SSPL — **нет**; MPL-2.0 — `web-push` (runtime, auth-worker), `lightningcss` (только сборка, в образ не попадает), `axe-core` (только тесты). Python: `psycopg` LGPL-3.0, `cryptography` Apache-2.0/BSD.

## Центральный коннектор (внутри образа, #617)

Агент коннектора написан на Go; его модули и лицензии: `github.com/nats-io/nats.go`, `nats-io/nkeys`, `nats-io/nuid` — Apache-2.0; `github.com/klauspost/compress` — BSD-3-Clause (с частями под Apache-2.0 и MIT); `golang.org/x/crypto`, `x/net`, `x/sys`, `x/term`, `x/text` — BSD-3-Clause; `gopkg.in/yaml.v3` — MIT и Apache-2.0; `gopkg.in/check.v1` — BSD-2-Clause (только тесты, в бинарник не входит). Плагины интеграций (Python) ставятся из каталога на сайте под своими манифестами; их зависимости — в каждом бандле.

## Системные пакеты образа

Образ сервисов `buff-community` собран от `debian:trixie-slim` и Windmill не содержит. Образ песочницы `buff-community-sandbox` не распространяется: `install.sh` собирает его на вашей машине поверх стокового образа Windmill, который вы загружаете сами на условиях его авторов (`sandbox/Dockerfile`). Системные пакеты Debian (ОС, библиотеки, `git`, `git-lfs`, `supervisor`, `python3`, `iptables`, Docker Engine внутри образа) распространяются под своими лицензиями, включая GPL/LGPL; они используются как есть, без изменений, их исходные тексты доступны в Debian и у авторов (Docker — Apache-2.0). Наш код в образе — отдельные файлы и процессы, не производные от этих пакетов.

## Инструменты на хосте, которые ставит `install.sh`

| Компонент | Лицензия |
|---|---|
| Docker Engine | Apache-2.0 |
| Sysbox (sysbox-ce) | Apache-2.0 |

## Уведомления

### Apache License 2.0
Этот продукт включает программное обеспечение, разработанное в рамках проектов NATS (The NATS Authors), Apache Tika (The Apache Software Foundation), Sysbox (Nestybox) и cryptography (The Python Cryptographic Authority), лицензированное по Apache License, Version 2.0. Текст лицензии: https://www.apache.org/licenses/LICENSE-2.0

### MIT License
Этот продукт включает программное обеспечение под лицензией MIT, в том числе opencode (© Anomaly Innovations), Gitea (© The Gitea Authors), Node.js, Bun, React и другие npm-пакеты. Текст лицензии: https://opensource.org/license/mit

### Mozilla Public License 2.0
`web-push` распространяется по MPL-2.0: https://www.mozilla.org/MPL/2.0/

### GNU Lesser General Public License v3
`psycopg` распространяется по LGPL-3.0: https://www.gnu.org/licenses/lgpl-3.0.html

### PostgreSQL License
https://www.postgresql.org/about/licence/
