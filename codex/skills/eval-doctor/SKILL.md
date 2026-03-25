# Skill: Eval Doctor

## When to use
Use when an agent evaluation (eval) is failing and you need to diagnose the root cause and fix the class of failures — not just patch the individual case.

Do **not** use when:
- The failure is a simple code bug unrelated to agent behavior (use normal debugging).
- You don't have traces or logs for the failing case(s) — collect them first.

## Inputs
- Eval name(s) / case id(s) that are failing.
- Commands to run the evals.
- Baseline results + pass thresholds.
- Dev set and held-out set definition (or selection rules).
- Per failing case: input, expected criteria, actual output, and agent trace (tool calls, intermediate steps) or equivalent logs.

## Procedure

### 1) Reproduce + measure variance
Run 3–5 trials for the failing case(s).
- Classify: consistent failure vs flaky.
- If flaky: report variance and focus on stabilizing the failure mode.

### 2) Locate the failure layer (trace-first)
From the trace, determine if the failure is primarily:
- **Tool/process failure** — wrong tool choice, missing tool call, bad loop, bad state.
- **Outcome failure** — final answer/behavior doesn't meet criteria.

Use trace evidence to support the classification.

### 3) Choose ONE primary root cause class (with evidence)
Pick the most likely primary cause:
- Spec/prompt contract ambiguity
- Retrieval/context missing/wrong/stale or poor selection guidance
- Tool contract/schema mismatch or tool outputs missing required context
- Decision logic/planning (routing, stopping, tool misuse)
- State/memory issues
- Architecture limitations

### 4) Propose 1–3 hypotheses + smallest general fix
For each hypothesis:
- Expected effect
- Regression risks
- Validation plan (which cases/metrics should improve)

Pick the least invasive fix that addresses the **class** of failures.

### 5) Apply fix (prefer generalization, avoid prompt bloat)
Fix priority order (deviate only with strong evidence):
1. Tool contract improvements (schemas, descriptions, returned context)
2. Decision logic / routing / planning / stop conditions
3. Retrieval / context selection improvements
4. Prompt / contract clarity (only what's needed)
5. Architecture changes (last resort)

### 6) Validate generalization (non-negotiable)
- Run on dev set (iterate).
- Run on held-out set (prove generalization).
- If stochastic, run multi-trial (3–5 runs) and report variance.
- Summarize: deltas overall + per-failure-class + worst regressions.

## Constraints (non-negotiable)
- No "add failing case to few-shot" unless held-out improves too.
- No brittle special-casing unless explicitly requested.
- No trace/logs → no diagnosis. First output must be what to collect.

## Deliverable format
```
FAILURE_SUMMARY:
- what failed, how often across trials

TRACE_EVIDENCE:
- key tool calls / steps that show the failure mode

PRIMARY_ROOT_CAUSE:
- category + evidence

FIX:
- chosen fix + why it generalizes

VALIDATION:
- dev set delta
- held-out delta
- regressions (if any)
```

## Stop conditions
- PASS: held-out set shows improvement with no significant regressions.
- FAIL: fix does not generalize to held-out, or introduces regressions.
  - Escalate with: what was tried, current metrics, suspected deeper cause.
