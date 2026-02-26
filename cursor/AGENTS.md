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

## Testing discipline
- **Bug fixes:** Write a failing test that reproduces the bug BEFORE fixing it.
- **New behavior:** Write the test first (expected inputs → outputs), then implement until it passes.
- **Refactors:** Ensure tests cover existing behavior before restructuring. Add characterization tests first if missing.
- **Skip test-first for:** config-only changes, prototypes, trivial one-liners, pure UI styling.
- Tests must be independent, deterministic, and fast. Prefer parametrized/table-driven tests.

## Dependency and secrets hygiene
- Prefer stdlib or already-installed packages. New deps need justification and pinned versions.
- Never hardcode secrets, API keys, or credentials in source. Use env vars or secret managers.
- Never log secrets. If accidentally committed, rotate immediately.

## Documentation lookup
When you need up-to-date docs for a library or framework, use Context7 MCP (`resolve-library-id` → `query-docs`) instead of relying on training data that may be stale.

## Safety
- Never run destructive operations against production systems/data.
- Never drop/delete/truncate collections/tables/indexes by default.
- If a destructive change is explicitly required: produce a migration plan + rollback plan + staging validation steps, then stop for explicit confirmation.
- **Destructive code must be written commented-out** with a `# REVIEW:` (or `// REVIEW:`) marker. Only the mutating lines (drop, delete, truncate, insert_many, update_many, seed, wipe, bulk mutations) are commented — surrounding logic is written normally. The user will review and uncomment.

## Docs
- Do not create new docs unless requested.
- Update existing docs only when behavior or public APIs change, and keep changes minimal.
