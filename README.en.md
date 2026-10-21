<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.svg">
    <img src="assets/logo.svg" alt="Buff Development" width="420">
  </picture>
</p>

<p align="center">
  <b>An AI developer, analyst and knowledge base for your company — on your machine, with your model.</b><br>
  Community Edition: free for the internal use of one organisation.
</p>

<p align="center">
  <a href="https://github.com/buffsystems/buff-community/releases"><img alt="Release" src="https://img.shields.io/github/v/release/buffsystems/buff-community?label=release&color=2563eb"></a>
  <a href="https://github.com/buffsystems/buff-community/pkgs/container/buff-community"><img alt="Image" src="https://img.shields.io/badge/ghcr.io-buff--community-2563eb?logo=docker&logoColor=white"></a>
  <a href="LICENSE.md"><img alt="Licence" src="https://img.shields.io/badge/licence-Buff%20Community-64748b"></a>
  <a href="https://buff.systems/docs/self-hosted/community"><img alt="Docs" src="https://img.shields.io/badge/docs-buff.systems-0b0d12"></a>
</p>

<p align="center">
  <a href="#install-in-five-minutes">Install</a> ·
  <a href="docs/install.en.md">Full guide</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="#videos">Videos</a> ·
  <a href="https://buff.systems/docs/self-hosted/community">Documentation</a> ·
  <a href="README.md">Русский</a>
</p>

---

**Buff** turns a tracker task into a ready branch with tests, answers questions about your company's documents and writes deep research — with AI agents that work autonomously but under human control. The Community Edition installs on your own machine with one command: code, tasks and documents never leave it, the model is yours (any OpenAI-compatible endpoint).

**Development by tasks** — 4:36, with sound (in Russian). Press play:

https://github.com/user-attachments/assets/32c45255-1b63-4d89-8dc4-956e112542cc

## What it does

| | |
|---|---|
| **Development by tasks** | Connect a repository (GitHub, GitLab, Gitea, Bitbucket), describe a task — the analyst clarifies it, the developer implements it in an isolated sandbox, the reviewer checks, the tests run. The result is a branch and a merge request. You approve the wording and the outcome. |
| **Ask** | A question about documents, policies and code — an answer backed by sources, with links. Read-only. For every department, not only engineers. |
| **Deep research** | Two agents — an analyst and a reviewer — work the question through your sources and produce a verified document: Markdown and PDF. |
| **Knowledge base** | What the team has found out stays in the organisation: entries with sources, used by people and agents alike. |
| **Buff Code** | A terminal for engineers: the same organisation, its models and knowledge base — from the command line. Sessions are visible in the cabinet. |
| **Connector** | A built-in connector to your git providers and knowledge sources (Notion, Confluence, Google Docs and more) — tokens stay on your machine. |

<p align="center">
  <img src="assets/shots/ask.png" alt="Ask: an answer from company documents with sources" width="430">
  <img src="assets/shots/research.png" alt="Deep research: the analyst's document after review" width="430">
</p>

## Install in five minutes

You need: Linux (Ubuntu 22.04/24.04, a user with `sudo`) or Docker Desktop on macOS/Windows; 4 CPU and 8 GB RAM; a key to an OpenAI-compatible model endpoint (OpenRouter, LiteLLM, vLLM, Ollama…). Detailed requirements are in the [guide](docs/install.en.md#requirements).

```sh
git clone https://github.com/buffsystems/buff-community.git
cd buff-community
./install.sh
```

The script asks for the organisation name, the administrator's e-mail and the model endpoint, installs Docker (and Sysbox on Linux), pulls the image, builds the agent sandbox and shows the first start right in the terminal — until the line **готово** (ready). Then:

- the application at `http://<host>:8138/app/`, login `admin`, password `ADMIN_PASSWORD` from `.env`;
- the admin panel at `http://<host>:8150`: users, model, workers, licence;
- the licence: in Admin → Licence enter the organisation and e-mail — the installation registers at buff.systems and receives the perpetual Community licence (3 users, 15 concurrent developments, one organisation).

Update: `git pull && ./install.sh`. Remove: `docker compose down -v`. Everything else is in the [full guide](docs/install.en.md): `.env` settings, the connector to your git providers, backups, troubleshooting, Docker Desktop — with screenshots.

## How it works

```
 browser ──▶ frontend ──▶ middleware (NATS) ◀──long-poll── Buff services ──▶ Gitea · Postgres · Windmill
                                                           │
                                            Windmill workers ──▶ agent sandboxes (inner docker)
                                                           │
                                            your model (OpenAI-compatible API) · your git providers
```

- **One image of ours**, `ghcr.io/buffsystems/buff-community` (~1.4 GB): all Buff services under a supervisor and an inner docker for the sandboxes. On Linux it is a Sysbox system container, no `privileged`; on Docker Desktop it runs privileged.
- **Stock images** of PostgreSQL, Gitea (internal git storage), NATS, Windmill (the orchestrator and its workers) and Apache Tika — from their registries, on their authors' terms.
- **The agent sandbox** is `buff-community-sandbox`, an image `install.sh` builds on your machine on top of Windmill (all language runtimes, as in SaaS). Every run gets its own container on an internal network: the only way out is the run's broker with the run's key, to the model and git at your addresses.
- **Nothing leaves your machine** except requests to your model, your git providers and the daily licence check at buff.systems (four fields: installation id, version, the number of users and runners).

## Videos

Three more videos with sound, in Russian (the mp4 files are attached to [release v0.21.1](https://github.com/buffsystems/buff-community/releases/tag/v0.21.1)):

**Buff in two minutes** — 1:23

https://github.com/user-attachments/assets/36d44fe2-071f-4b3c-86b0-2aad825b9b02

**Questions and the knowledge base** — 2:40

https://github.com/user-attachments/assets/d788e831-584d-4707-858d-f3956e9b24b1

**Buff Code** — 3:22

https://github.com/user-attachments/assets/481da974-11fa-495a-a660-3549f52888a2

<p align="center">
  <img src="assets/shots/knowledge.png" alt="The organisation's knowledge base" width="430">
  <img src="assets/shots/home.png" alt="A project: repository, tasks, audits" width="430">
</p>

## Editions

| | Community | Enterprise on-premise | SaaS |
|---|---|---|---|
| Where it runs | your machine | your perimeter | buff.systems |
| Organisations | one | one per licence | as many as needed |
| Users | up to 3 | unlimited | unlimited |
| Tasks in progress at once | up to 15 | unlimited | unlimited |
| Single sign-on, audit, support | — | yes | yes |
| Model | yours | yours | ours or yours |
| Price | free | a licence per organisation, monthly | per token |

More: [Editions](https://buff.systems/docs/self-hosted) and [pricing](https://buff.systems/pricing).

## Contributing and licence

This repository is the installation kit: `install.sh`, `docker-compose.yml`, connector settings, documentation. Kit changes, translations and bug reports go through [issues](https://github.com/buffsystems/buff-community/issues) and pull requests; the rules are in [CONTRIBUTING.en.md](CONTRIBUTING.en.md) (including AI-assisted changes). The source code of the services ships as an image and is not open.

Licence — [Buff Community Edition](LICENSE.md): internal use by one organisation, no resale or services to third parties. Third-party components — [THIRD-PARTY.md](THIRD-PARTY.md).
