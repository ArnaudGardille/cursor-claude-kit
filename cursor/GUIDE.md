# Cursor setup guide for teams: Rules, Skills, Subagents 

This is a practical, team-shareable setup for building agents in Cursor without turning your repo into a prompt museum.

It follows Cursor’s recommended building blocks:

- **Rules** for persistent, scoped repo conventions: [Rules](https://cursor.com/docs/context/rules)
- **Subagents** for specialized reviewers / workflows: [Subagents](https://cursor.com/docs/context/subagents)
- **Skills** for small, repeatable procedures: [Agent Skills](https://cursor.com/docs/context/skills)
- **Hooks** for hard enforcement (especially safety): [Hooks](https://cursor.com/docs/agent/hooks)

DeepEval guidance is used specifically for *agent evaluation and debugging*:

- Evaluate reasoning + tool use + task completion separately: [AI Agent Evaluation](https://deepeval.com/guides/guides-ai-agent-evaluation)

---

## 1) Rules (`.cursor/rules/*.mdc`)

### What rules are for

Rules are **persistent guardrails** and **team conventions** that Cursor can apply automatically based on file patterns (`globs`) or relevance. Keep them short and high leverage.
See: [Rules](https://cursor.com/docs/context/rules)

### Best-practice format

Use **`.mdc`** (Markdown + YAML frontmatter) so you can scope rules cleanly:

- `description`: what the rule is for (helps discoverability)
- `globs`: where it applies (reduces context bloat)

Cursor explicitly supports `.md` and `.mdc`, and recommends `.mdc` frontmatter for tighter control.
See: [Rules](https://cursor.com/docs/context/rules)

### Recommended rule split (minimal, effective)

1) **00-safety.mdc** (always on)

- Non-negotiables: no destructive prod actions, no silent data deletion
- If destructive change is required: migration + rollback + staging validation + explicit confirmation

2) **10-quality.mdc** (Python files only)

- Minimal diffs (no ornamental refactors)
- Error discipline (typed exceptions, boundary-only catching, no swallowed errors)
- Packaging/resources (prefer `importlib.resources` over brittle path hacks)

3) **20-evals.mdc** (manual attach or narrow scope)

- When evals fail: investigate root cause, don’t “just add the failing case”
- Generalization requirement: dev set + held-out set

> Tip: Don’t get fancy with globs. Keep scopes stable and predictable.

---

## 2) Hooks (enforcement layer)

### Why hooks matter

Rules are guidance. If something is truly forbidden (e.g., destructive commands), use **hooks** to enforce it. Hooks can **observe, block, or modify agent behavior** during the agent loop.
See: [Hooks](https://cursor.com/docs/agent/hooks)

### What hooks are best at (high ROI)

- Blocking destructive shell commands (drop/truncate/delete/mass updates)
- Forcing “verification evidence” (tests ran) before allowing “done”
- Logging/verdict capture from a verifier step

If your team cares about “not breaking prod,” hooks are the seatbelt. Rules are a sticky note.

---

## 3) Skills (for repeatable procedures, not reasoning)

### What skills are for

Skills package **reusable, procedural workflows** (and optionally scripts/resources) that agents can load on demand.
See: [Agent Skills](https://cursor.com/docs/context/skills)

### When a skill beats a subagent

Use a skill when the task is:

- Mechanical / deterministic
- Repetitive
- Best expressed as a short loop with stop conditions

### Recommended skill: “Lint + Mypy Fix Loop”

Use this as a skill (not a subagent) because it’s a simple iterative procedure:

- Input: failing command + full output
- Loop: fix minimal → rerun → repeat up to N times
- Guardrails: don’t weaken types (`Any`, broad ignores) unless justified; no refactors

This aligns with Cursor’s suggestion that simple “single purpose” helpers are better as skills than as subagents.
See: [Subagents](https://cursor.com/docs/context/subagents) and [Agent Skills](https://cursor.com/docs/context/skills)

---

## 4) Subagents (specialists with clear responsibilities)

### What subagents are for

Subagents are specialist “roles” defined under `.cursor/agents/` with YAML frontmatter (`name`, `description`, `model`). Cursor uses the **description** to decide when to delegate.
See: [Subagents](https://cursor.com/docs/context/subagents)

### Recommended minimal set (the ones that actually pay for themselves)

#### A) Verifier (fast model)

**Job:** prevent “looks done” lies.

Key behaviors:

- Reject ornamental refactors / drive-by changes
- Check safety hazards (destructive ops, prod config changes)
- Require evidence of checks run (lint/typecheck/unit tests/integration when relevant)

**Best practice upgrade:** Structured output so hooks/CI can parse it:

- `VERDICT: PASS|FAIL`
- `CHECKS_RUN: …`
- `SAFETY_RISK: …`
- `NEXT_STEPS: …`

Cursor’s docs explicitly recommend a verifier-style subagent that is skeptical and validates work by running tests and checking edge cases.
See: [Subagents](https://cursor.com/docs/context/subagents)

#### B) Eval Doctor (normal model)

**Job:** turn failing agent evals into *general improvements*.

DeepEval’s key idea: evaluate an agent by layer (reasoning, tool use, overall completion) so you can pinpoint what’s broken.
See: [AI Agent Evaluation](https://deepeval.com/guides/guides-ai-agent-evaluation)

Eval Doctor should be:

- **Trace-first** (no tool trace/logs → request what to collect)
- **Metric-driven** (use agent metrics to locate failures)
- **Generalization-focused** (dev set + held-out set; multi-trial if stochastic)

Use DeepEval agent evaluation thinking: evaluate reasoning layer vs action/tool layer vs overall task completion separately.
See: [AI Agent Evaluation](https://deepeval.com/guides/guides-ai-agent-evaluation)

### Optional (add if your team hits test failures often)

#### C) Debugger (normal model)

**Job:** reproduce failing tests/errors, isolate root cause, minimal fix, rerun failing test then suite.

This one is useful when failures are frequent and you want to reduce “random edit until green” behavior.

---

## Decision cheat sheet (what goes where)

- **Rules**: stable constraints and conventions (keep short; scope via globs)→ [Rules](https://cursor.com/docs/context/rules)
- **Hooks**: enforcement and safety (block/allow/modify behavior)→ [Hooks](https://cursor.com/docs/agent/hooks)
- **Skills**: small repeatable procedures (mechanical loops)→ [Agent Skills](https://cursor.com/docs/context/skills)
- **Subagents**: specialized reasoning roles (Verifier, Eval Doctor)
  → [Subagents](https://cursor.com/docs/context/subagents)

---

## Suggested starting package for a team

If you want the “minimum effective bureaucracy” setup:

1) Rules:

- `00-safety.mdc`
- `10-quality.mdc`
- `20-evals.mdc` (manual attach)

2) One skill:

- `Lint + Mypy Fix Loop`

3) Two subagents:

- `Verifier` (fast)
- `Eval Doctor` (normal)

4) Hooks (if you care about real safety):

- block destructive commands
- require/verifier structured verdict before completion
