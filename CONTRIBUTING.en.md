# Contributing

*[Русская версия](CONTRIBUTING.md)*

Thank you for helping. This repository is the **installation kit** of the Community Edition: `install.sh`, `docker-compose.yml`, connector settings, documentation and translations. The source code of the Buff services is not part of it — it ships as the image `ghcr.io/buffsystems/buff-community` and is not open, so product changes are accepted only as proposals in issues.

## What to send

- **Installation and runtime bugs** — via [issues](https://github.com/buffsystems/buff-community/issues). Give the version (`BUFF_IMAGE` from `.env`), the OS and mode (Linux/Sysbox or Docker Desktop), what you did, what you expected, what happened, and attach `docker compose logs buff` for the relevant time. Strip tokens and passwords from the output first.
- **Kit changes** — `install.sh`, compose, example settings, documentation and translations — via a pull request.
- **Product proposals** — an issue labelled "proposal": what you want, why, and how it looks to the user.

Enterprise purchases and commercial questions go through [buff.systems](https://buff.systems/#contact), not here.

## Pull requests

1. One change per PR. Small and described: what changes and why.
2. Verify on a clean machine: `./install.sh` from scratch reaches "готово" (ready), the application and admin open. Say in the PR where you verified (OS, mode).
3. Commits follow [Conventional Commits](https://www.conventionalcommits.org/): `fix(install): …`, `docs: …`.
4. Documentation is bilingual: if you edit `README.md`, edit `README.en.md` too (and vice versa).
5. No secrets, binaries or new dependencies without discussion in an issue.

By submitting changes you confirm you have the right to do so and allow buff.systems to use them in the product and its editions under [LICENSE.md](LICENSE.md).

## Changes made with AI assistance

Using AI assistants (Claude, Copilot, Buff and others) is fine — we work that way ourselves. The rules:

- **A human is responsible.** You have read and understood every line you submit and verified it by running it. "The model did it" is not an argument in a discussion.
- **Say so.** Add the trailer `Assisted-with: <tool>` to the commit message (e.g. `Assisted-with: Claude Code`). Do not credit an AI as a human co-author (`Co-authored-by`).
- **No flood.** Do not send batches of generated PRs or issues "just in case". Issues without a reproduction and PRs not verified on a machine are closed.
- **No one else's secrets or data.** Tokens, passwords and logs with personal data never reach the model's context — and therefore never reach a PR.
- Text the model wrote for you (PR description, comment) must be to the point and shorter than you think.
