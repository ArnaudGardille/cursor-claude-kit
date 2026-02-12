---
name: "lint-fix"
description: "Iteratively fix ruff/mypy issues with minimal diffs until checks pass (max 3 iterations)."
auto: false
---

# Skill: Lint + Mypy Fix Loop

## When to use
Use after running `ruff` / `mypy` (and optionally `pytest`) when failures are mainly lint/type issues and the fix should be mechanical and minimal.

## Inputs
- The exact command that failed (e.g., `ruff check .` or `mypy .`)
- The full error output

## Procedure
1) Parse the error output and group errors by file.
2) Apply the minimal code edits that fix the reported errors.
3) Re-run the exact same command.
4) Repeat up to 3 iterations.

## Constraints (non-negotiable)
- Minimal diff. No refactors, no renames unless required by the error.
- Do not weaken typing to silence mypy:
  - avoid `Any` unless truly correct
  - avoid broad `# type: ignore` unless justified (include a short justification comment)
- Do not change runtime behavior unless required to fix a real bug revealed by typing/linting.
- Do not edit unrelated files.

## Stop conditions
- PASS: command exits clean.
- FAIL: after 3 iterations or if errors suggest design/behavior issues rather than typing/lint.
  - Escalate to Debugger (or main session) with:
    - what was tried
    - current errors
    - suspected root cause
