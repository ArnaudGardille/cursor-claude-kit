# CLAUDE.md

This repository is configured for agent-assisted development with strong safety and verification defaults.

## Definition of Done
A change is "done" only when:
- The implementation matches the requested behavior.
- The diff is minimal (no ornamental refactors).
- Relevant checks were run and passed.
- You report exactly what you ran and any notable output.

## Safety (non-negotiable)
- Never execute destructive operations against production systems/data.
- Never drop/delete/truncate collections/tables/indexes by default.
- If a destructive change is explicitly required: provide a migration plan + rollback plan + staging validation steps, then stop for explicit confirmation.

## Error discipline
- Validate inputs at boundaries (API/CLI/job entrypoints).
- Raise typed exceptions with clear messages.
- Catch exceptions only at system boundaries to add context or map to correct responses.
- Never swallow exceptions silently.

## Minimal change policy
- Prefer the smallest change that solves the request.
- No refactors unless required for the task or explicitly requested.
- Avoid drive-by renames/reformatting unrelated to the request.

## Packaging/resources (Python)
- Prefer `importlib.resources` for package data.
- Avoid filesystem-relative hacks like `Path(__file__).parent.parent...`.

## Commands (edit to match this repo)
- Lint: `ruff check .`
- Format: `ruff format .`
- Typecheck: `mypy .`
- Unit tests: `pytest -q`
- Integration tests: `pytest -q tests/integration`

## How to work with eval failures
- Do not “fix” eval failures by adding the failing case to few-shot by default.
- Use the Eval Doctor agent to diagnose root cause and validate improvements on dev + held-out eval sets.
