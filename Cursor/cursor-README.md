# Cursor Agent Setup

This folder contains Cursor rules and subagents designed to keep changes:
- safe (avoid destructive actions),
- minimal (no ornamental refactors),
- verifiable (tests/typechecks run),
- evaluation-driven (agent improvements generalize).

## Files
- `AGENTS.md`: repo-wide instructions, commands, definition of done.
- `00-safety.mdc`: always-on safety constraints.
- `10-quality.mdc`: always-on minimal-diff + error discipline + packaging.
- `20-evals.mdc`: only for agent/eval-related work (scoped via globs).
- `verifier.md`: skeptical validation before declaring “done”.
- `eval-doctor.md`: root-cause analysis + generalization for eval failures.

## Notes
- Rules are scoped via `.mdc` frontmatter so they don’t bloat every context.
- For non-negotiable safety (blocking destructive actions), prefer Hooks as enforcement.
