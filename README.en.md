# Buff Community Edition

*[Русская версия](README.md)*

The free edition of [Buff](https://buff.systems) for the internal use of one organisation: AI development by tasks, "Ask", deep research and a knowledge base — on your own machine, with your own model. Full documentation: [buff.systems/docs/self-hosted/community](https://buff.systems/docs/self-hosted/community); how Community differs from SaaS and Enterprise: [Editions](https://buff.systems/docs/self-hosted). Licence: [LICENSE.md](LICENSE.md).

## Requirements

| | Requirement |
|---|---|
| Linux | Ubuntu 22.04 or 24.04 (amd64), kernel 5.7 or newer, a user with `sudo`. Runners work inside [Sysbox](https://github.com/nestybox/sysbox) — no privileged containers |
| macOS, Windows | [Docker Desktop](https://docs.docker.com/desktop/); on Windows run the script from Git Bash. **There is no Sysbox here, so our container runs privileged** — fine for a personal machine, not for a server |
| Resources | at least 4 CPU and 8 GB RAM (one development at a time); 8 CPU and 16 GB recommended for three concurrent ones. About 20 GB of disk for images plus room for your repositories: data lives in Docker volumes, not in the image |
| Internet | images from ghcr.io and Docker Hub, the daily licence check at buff.systems, your model endpoint |
| Model | a key to an OpenAI-compatible endpoint: [OpenRouter](https://openrouter.ai), your own LiteLLM, vLLM, Ollama, etc. |

## Install

```sh
git clone https://github.com/buffsystems/buff-community.git
cd buff-community
./install.sh
```

The script picks the mode itself. On Linux it installs Docker and Sysbox; with Docker Desktop it uses it and adds `docker-compose.desktop.yml` (privileged mode). Then, in both cases: it creates `.env` with random passwords, downloads the edition image, brings `docker compose` up and shows the first start's progress right in the terminal until "готово" (ready) — a few minutes: databases, accounts, pipeline deployment. Run it as a regular user; root is not needed.

Before the first login open `.env` and fill in:

| Variable | What it is |
|---|---|
| `ORG` | your organisation's name in Latin letters (`acme`) |
| `ADMIN_USER`, `ADMIN_EMAIL`, `ADMIN_PASSWORD` | the first user of the application and its administrator (the password is generated) |
| `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL` | endpoint, key and model, e.g. `https://openrouter.ai/api/v1`, `sk-or-…`, `openai/gpt-4.1` |
| `APP_URL` | the address people open the application at (default: the machine's IP, port 8138) |
| `RUNNERS` | how many development workers to start — that many developments run concurrently (default 3, up to 1.5 GB RAM each). A value above the licence limit has no effect: the limit is signed into the licence and shown in Admin → Licence (Community: 15) |

Changed `.env` — `docker compose up -d` applies it.

## First login

- Application: `APP_URL` (`http://<host>:8138/app/`), login `ADMIN_USER` with the password from `.env`.
- Admin: `http://<host>:8150`, user `admin`, the same password. Sections: users (the administrator creates them), model configuration, workers, licence.
- Licence: in Admin → Licence enter the organisation and e-mail and confirm consent to processing them — the installation registers at buff.systems on its next check and receives the perpetual Community licence: 3 users, 15 concurrent developments, one organisation. The limits are shown there. Without a licence new tasks do not start; login and reading keep working.

## Update

```sh
git pull
./install.sh
```

Put the new `BUFF_IMAGE` from the updated `.env.example` into `.env` — the script downloads the image and restarts the containers. Database migrations run at start. Data lives in the volumes `pgdata`, `gitea-data`, `buff-data`, `buff-docker`: a backup is `docker compose stop` plus a copy of the volumes.

## Troubleshooting

- `docker compose ps`, `docker compose logs buff` — our container keeps its services under a supervisor: `docker compose exec buff supervisorctl status`.
- Repeating the first start is safe: `docker compose exec buff buff-bootstrap`.
- Questions and bugs go to this repository's [issues](https://github.com/buffsystems/buff-community/issues); see [CONTRIBUTING.en.md](CONTRIBUTING.en.md) for how to file them. No support is provided for the Community Edition.

## Central connector

The installation's only connector starts inside the container and pairs with your organisation by itself. Git providers and tokens live in `connector/connector.yaml`; after editing: `docker compose exec buff supervisorctl restart services:connector`. Details: [documentation](https://buff.systems/docs/self-hosted/community).

## What is inside

Stock images of PostgreSQL, Gitea, NATS, Windmill (server), Apache Tika and one image of ours, `buff-community`, with all Buff services. Third-party licences: [THIRD-PARTY.md](THIRD-PARTY.md). Windmill is downloaded from ghcr.io on its authors' terms and is not part of our image.

## Contributing

Changes to the installation, documentation and translations, bug reports — see [CONTRIBUTING.en.md](CONTRIBUTING.en.md), including the rules for changes made with AI assistance.
