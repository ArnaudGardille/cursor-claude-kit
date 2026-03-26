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
- Never run broad cleanup scripts without an explicit target and rollback plan.
- If a destructive change is explicitly required, you must provide:
  1. Exact operations to run (commands/queries).
  2. Migration strategy (including staging validation).
  3. Rollback strategy.
  4. A clear checkpoint that asks for explicit confirmation before applying.

### Destructive code must be written commented-out
When writing code that contains destructive operations (drop, delete, truncate, insert_many, update_many, remove, destroy, purge, overwrite, seed, wipe, or any bulk mutation), **always write those lines commented-out** with a `# REVIEW:` (or `// REVIEW:` in TS/JS) marker explaining what the line does. Only the mutating lines are commented — surrounding logic is written normally. The user will review and uncomment.

## Error discipline
- Validate inputs at boundaries (API/CLI/job entrypoints).
- Raise typed exceptions with clear messages.
- Catch exceptions only at system boundaries to add context or map to correct responses.
- Never swallow exceptions silently.

## Minimal change policy
- Prefer the smallest change that solves the request.
- No refactors unless required for the task or explicitly requested.
- Avoid drive-by renames/reformatting unrelated to the request.

## Keep code simple
- Avoid one-off helper functions used only once unless they materially improve readability.
- Avoid duplicating constants/examples/datasets; keep a single source of truth.
- Prefer existing project utilities/patterns over inventing new ones.

## Testing discipline
- **Bug fixes:** Write a failing test that reproduces the bug BEFORE fixing it. No regression test means the bug will return.
- **New behavior with clear I/O:** Write the test (expected inputs/outputs) first, then implement until it passes.
- **Refactors:** Ensure tests cover existing behavior before restructuring. Add characterization tests first if coverage is missing.
- **Skip test-first for:** config-only changes, prototype/spike code, trivial one-liners, pure UI styling.
- Tests must be independent, deterministic, and fast. Prefer parametrized/table-driven tests for multiple cases.

## Dependency and secrets hygiene
- Prefer stdlib or already-installed packages. New deps require justification and pinned versions.
- No duplicate-purpose dependencies.
- Never hardcode secrets, API keys, or credentials in source. Use env vars or secret managers.
- Never log secrets. If a secret is accidentally committed, rotate it immediately.

## Packaging/resources (Python)
- Prefer `importlib.resources` for package data.
- Avoid filesystem-relative hacks like `Path(__file__).parent.parent...`.

## TypeScript conventions
- Avoid `any`; prefer `unknown` when the type is truly unknown and narrow from there.
- Use strict TypeScript (`strict: true` in tsconfig).
- Prefer interfaces for object shapes; use type aliases for unions/intersections.
- Validate inputs at boundaries (API routes, CLI entrypoints, event handlers).
- Use typed errors or custom Error subclasses with clear messages.
- Never swallow exceptions silently (no empty catch blocks).

## Observability (agent execution)
Traces are required to debug, evaluate, and improve agent behavior. No trace means no diagnosis.
- **LLM calls:** capture model, prompt (or hash), completion, tokens, latency, cost.
- **Tool calls:** log tool name, inputs, outputs, duration, and errors.
- Use a span/step ID so steps can be ordered and attributed.
- Use a correlation/trace ID that links all steps of a single agent run; propagate it through the full execution.
- Use structured logging (JSON or equivalent); no bare `print()` for agent execution data.
- Redact sensitive data (API keys, PII) before logging; never log full prompts or responses that contain secrets.

## Tool contracts (agent tools)
Treat tool definitions as first-class prompt engineering. Clear boundaries and returns prevent whole classes of agent failures.
- **Description:** state what the tool does AND what it does not do. Include at least one example call and expected return shape for non-obvious interfaces. Document edge cases and input format requirements; distinguish from similar tools.
- **Schema:** every parameter has a type, description, and constraints. Prefer absolute identifiers over relative. Make arguments hard to misuse (enums over free text where appropriate).
- **Returns:** must include actionable context the agent can reason over (not just "ok" or raw status codes). Return enough info for the agent to decide the next step.
- **Errors:** must be structured and meaningful — category, message, and suggested recovery. Do not surface raw tracebacks; map to agent-friendly error payloads.

## Git worktree awareness
Before making code changes, check the current branch (`git branch --show-current`).
If you are on `main`, `master`, `develop`, or a branch **unrelated** to the requested task:
1. **Do not** switch branches or commit to the current branch.
2. **Resolve the target branch:** search local and remote branches for one that matches the task. If no branch exists, propose a new branch name following the repo's naming convention and confirm with the user.
3. Create a **git worktree** and perform all work there.
4. Follow the full procedure in the **`git-worktree`** skill (`claude/skills/git-worktree/SKILL.md`).

This applies even when the user does not explicitly mention a branch. If you are on `main` and the user says "implement X", you still need a feature branch — find or create one via worktree.

## Commands (edit to match this repo)
- Lint: `ruff check .`
- Format: `ruff format .`
- Typecheck: `mypy .`
- Unit tests: `pytest -q`
- Integration tests: `pytest -q tests/integration`

## Documentation lookup
When you need up-to-date docs for a library or framework, use Context7 MCP (`resolve-library-id` → `query-docs`) instead of relying on training data that may be stale.

## How to work with eval failures
Do NOT default to fixing by adding the failing case to few-shot. Instead:
1. Reproduce the failure (capture inputs, tool traces, and outputs).
2. Categorize the likely root cause:
   - Spec/prompt contract ambiguity
   - Missing/incorrect context or retrieval
   - Tool interface/schema issues
   - Decision logic/planning policy issues
   - Memory/state issues
   - Agent architecture limitations
3. Propose 1–3 hypotheses and choose the smallest general fix.

### Generalization requirement
- Validate improvements on a small dev set (fast iteration) AND a held-out set (generalization).
- If stochastic, run multi-trial (3–5 runs) and report variance before concluding pass/fail.
- Only add examples to few-shot if the example represents a recurring failure class AND it improves held-out performance.
- Report before/after results (metrics or concise summary across multiple cases).
- Prefer robustness improvements that do not increase prompt bloat.

## Prompt discipline
Prompts are versioned artifacts. Fight bloat and contradictions; tie changes to measurable impact.
- Tag meaningful prompt changes with a version comment or changelog entry so you can correlate versions with metric deltas.
- New instructions must replace or consolidate existing ones; no unbounded growth.
- Keep prompt structure clear: use delimiters/sections; avoid contradictory instructions across sections.
- Avoid embedding large static data in prompts; prefer retrieval or tool-based context injection.
- If a prompt change targets eval improvement, report before/after metrics on a small eval slice before merging.
