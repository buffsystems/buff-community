# Buff Community Edition

Бесплатное издание [Buff](https://buff.systems) для внутреннего использования одной организацией: ИИ-разработка по задачам, «Спросить», исследования и база знаний — на вашей машине, с вашей моделью. Лицензия — [LICENSE.md](LICENSE.md); чем Community отличается от SaaS и Enterprise — на [сайте](https://buff.systems/docs/self-hosted).

## Что нужно

- Выделенная виртуальная машина: Ubuntu 22.04 или 24.04 (amd64), ядро ≥ 5.7, 8 CPU, 32 ГБ памяти, диск от 300 ГБ (образы и репозитории). Не Docker Desktop.
- Пользователь с `sudo` (ставить под root не нужно).
- Доступ в интернет: образы с ghcr.io и Docker Hub, суточная проверка лицензии на buff.systems.
- Ключ к OpenAI-совместимому эндпоинту модели: OpenRouter, свой LiteLLM, vLLM и т. п.

## Установка

```sh
git clone https://github.com/buffsystems/buff-community.git
cd buff-community
./install.sh
```

Пока издание не опубликовано, репозиторий и пакет образа на GitHub закрыты: клонируйте с токеном GitHub, у которого есть `repo` и `read:packages`, и передайте тот же токен скрипту — он войдёт в ghcr.io и сохранит образ файлом в `images/` для внутреннего докера песочниц:

```sh
git clone https://<токен>@github.com/buffsystems/buff-community.git
cd buff-community
GHCR_TOKEN=<токен> ./install.sh
```

`install.sh` ставит Docker и [Sysbox](https://github.com/nestybox/sysbox) (в нём раннеры инструментов разработки работают без `privileged`), создаёт `.env` со случайными паролями и поднимает `docker compose`. Первый старт занимает несколько минут: следить — `docker compose logs -f buff`, готовность — строка `готово`.

До первого входа откройте `.env` и впишите:

| Переменная | Что это |
|---|---|
| `ORG` | имя вашей организации латиницей (`acme`) |
| `ADMIN_USER`, `ADMIN_EMAIL`, `ADMIN_PASSWORD` | первый пользователь приложения и администратор (пароль сгенерирован) |
| `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL` | эндпоинт, ключ и модель, например `https://openrouter.ai/api/v1`, `sk-or-…`, `openai/gpt-4.1` |
| `APP_URL` | адрес, по которому люди откроют приложение (по умолчанию — IP машины, порт 8138) |
| `RUNNERS` | сколько разработок идут одновременно (не больше предела лицензии, по умолчанию 3) |

Изменили `.env` — `docker compose up -d` применит.

## Первый вход

- Приложение: `APP_URL` (`http://<машина>:8138/app/`), логин `ADMIN_USER` с паролем из `.env`. Код по почте не требуется.
- Админка: `http://<машина>:8150`, пользователь `admin`, тот же пароль. Разделы: пользователи (новых заводит администратор), модель, воркеры, лицензия.
- Лицензия: в админке → «Лицензия» укажите организацию и почту — инсталляция зарегистрируется на buff.systems при ближайшей проверке и получит бессрочную лицензию Community (3 пользователя, до 15 раннеров). Без лицензии новые задачи не стартуют, вход и чтение работают.

## Обновление

```sh
git pull
docker compose pull && docker compose up -d
```

Миграции базы применяются при старте. Данные — в томах `pgdata`, `gitea-data`, `buff-data`, `buff-docker`: бэкап = `docker compose stop` + копия томов.

## Диагностика

- `docker compose ps`, `docker compose logs buff` — наш контейнер держит сервисы под супервизором: `docker compose exec buff supervisorctl status`.
- Повторить первый старт безопасно: `docker compose exec buff buff-bootstrap`.
- Вопросы и ошибки — в issues этого репозитория. Поддержка Community Edition не предоставляется.

## Состав

Стоковые образы PostgreSQL, Gitea, NATS, Windmill (сервер), Apache Tika и один наш образ `buff-community` со всеми сервисами Buff. Сторонние лицензии — [THIRD-PARTY.md](THIRD-PARTY.md). Windmill загружается с ghcr.io на условиях его авторов и не входит в наш образ.

---

**English.** Buff Community Edition: free, for internal use of one organisation. Requirements: a dedicated Ubuntu 22.04/24.04 VM (kernel ≥ 5.7, 8 CPU, 32 GB RAM, 300 GB disk), a sudo user, internet access, an OpenAI-compatible model endpoint key. Install: clone, `./install.sh`, fill `ORG`, `ADMIN_*`, `LLM_*` in `.env`, `docker compose up -d`. App at `http://<host>:8138/app/`, admin at `:8150`. Register the installation in Admin → Licence to receive the perpetual Community licence (3 users, 15 runners). Update with `git pull && docker compose pull && docker compose up -d`. Licence: [LICENSE.md](LICENSE.md).

## Центральный коннектор

Единственный коннектор установки запускается внутри контейнера и сопрягается с вашей организацией сам. Git-провайдеры и токены — в `connector/connector.yaml`; после правки: `docker compose exec buff supervisorctl restart services:connector`. Подробнее — в [документации](https://buff.systems/docs/self-hosted/community).
