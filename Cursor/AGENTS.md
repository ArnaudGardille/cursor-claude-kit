# AGENTS.md

This repo is intended for agent-assisted development.

## Environment
- Activate venv: `source .venv/bin/activate`

## Definition of Done
A change is "done" only when:
- The implementation matches the requested behavior.
- The diff is minimal (no ornamental refactors).
- You ran the relevant checks and they passed.
- You report what you ran and any notable output.

## Commands (edit to match this repo)
- Lint: `ruff check .`
- Format: `ruff format .`
- Typecheck: `mypy .`
- Unit tests: `pytest -q`
- Integration tests: `pytest -q tests/integration`

## Safety
- Never run destructive operations against production systems/data.
- Never drop/delete/truncate collections/tables/indexes by default.
- If a destructive change is explicitly required: produce a migration plan + rollback plan + staging validation steps, then stop for explicit confirmation.

## Docs
- Do not create new docs unless requested.
- Update existing docs only when behavior or public APIs change, and keep changes minimal.
