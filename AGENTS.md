# AGENTS.md

Directives for AI agents working in this repository.

Project context (purpose, architecture, setup) lives in `README.md`. Do not duplicate it here.

## Non-negotiables

- **No secrets on iPhone**. The iPhone is a trigger/UI layer only.
- **Secrets live on the Mac only** (typically `config/env.sh`). Never add secrets to the repo.
- **Never print secrets** to stdout or to file logs (tokens, keys, auth headers).
- **One SSH trigger = one intent**. Keep workflows atomic and predictable.
- **Do not touch git**: no `git add` / `commit` / `push`, no branch operations.

## Repo conventions

### Workflows (shell scripts)

- Put workflows under an integration folder (example: `clickup/`).
- Prefer a single script per action (example: `clickup/create_task.sh`).
- Scripts must be non-interactive and fast.
- Avoid duplicating heavy validation: the iPhone Shortcut is the validation/UI layer.
- Do not add environment variable presence checks in scripts; env vars are declared in `config/env.example.sh` and configured locally in `config/env.sh`.
- Keep scripts focused on executing the action and returning the standard response.
- Do not add shell function declarations in `.sh` files; prefer a flat, linear flow.
- Prefer `~` paths over `$HOME` in shell scripts.
- Do not create directories at runtime (`mkdir`); required folders must already exist in the repo (track empty ones with `.gitkeep`).

### Configuration

- `config/env.example.sh` is the template (safe to commit).
- `config/env.sh` is local-only (ignored by git) and contains real secrets.
- Env values must be canonical and ready to use. Do not normalize or repair env values in scripts.
  - Example: `CLICKUP_BASE_URL` has no trailing slash, `CLICKUP_INBOX_PATH` has no leading slash.
- When adding a new env var:
  - Add it to `config/env.example.sh` (empty value)
  - Document it in `README.md` (Configuration)

### Logging

- Log files live in `vars/logs/` and are local-only (ignored by git).
- Prefer one file per workflow (example: `vars/logs/clickup.log`).
- Keep logs consistent and redact sensitive data.
- On success, never log full API payloads/responses; log a compact status or extracted identifier only.
- On error, short API error bodies are acceptable when useful, but never log secrets.
- See `docs/logging.md`.

## When to write an ADR

Add a short decision record in `docs/decisions/` when a change affects:

- security boundaries (what runs where, secret handling)
- the trigger/execution architecture (Shortcuts / SSH / Mac)
- output/logging contracts that other workflows depend on

## Definition of done (new workflow)

- Script added in the right integration folder
- Required env vars added to `config/env.example.sh` and documented in `README.md`
- Logging added per `docs/logging.md`
