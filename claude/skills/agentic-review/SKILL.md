---
name: "agentic-review"
description: "Review this repository as an AI agent systems reviewer."
auto: false
---

Review this repository as an AI agent systems reviewer.

Your job is not to do a general code review. Your job is to review the quality of the agentic system itself: prompts, instructions, tools, schemas, orchestration, context management, model choices, guardrails, observability, and eval readiness.

Context:
This repository contains one or more AI agents, agent workflows, or LLM-powered tool-using systems. It may include system prompts, developer prompts, agent policies, tool definitions, structured output schemas, memory or retrieval logic, orchestration code, guardrails, model routing, and evaluation or tracing infrastructure.

Goal:
Identify the highest-leverage improvements to make the agent more reliable, interpretable, robust, maintainable, and safe to evolve.

What to review:

1. Agent instructions and prompting
- Are system, developer, and task-level instructions consistent, clear, and non-contradictory?
- Are roles, priorities, constraints, and stopping conditions explicit?
- Are there vague instructions, hidden assumptions, duplicated rules, or conflicting behaviors?
- Does the prompt clearly define what the agent should do, what it must never do, and what it should do when uncertain?
- Are the prompts too long, too brittle, or overloaded with policy and implementation detail?

2. Tooling quality and tool-use ergonomics
- Are tools described clearly enough for an LLM to select them correctly?
- Are tool names, descriptions, argument names, types, and required fields unambiguous?
- Are tool inputs and outputs structured, typed, and easy for the model to reason about?
- Do tools expose stable contracts, predictable error modes, and useful return values?
- Are there tools that are too broad, too overlapping, too low-level, or too under-specified?
- Can the agent recover from tool failures, empty results, malformed responses, rate limits, and retries?
- Are there missing tools that would materially simplify the agent?

3. Input/output contracts
- Are expected user inputs, intermediate state objects, tool schemas, and final outputs clearly specified?
- Is structured output used where it should be?
- Are parsing assumptions fragile or dependent on natural-language formatting?
- Are types, enums, nullable fields, defaults, and edge cases clearly handled?
- Are there silent schema mismatches between prompts, code, and runtime behavior?

4. Context engineering and state management
- Is the agent given the right context at the right time?
- Is irrelevant context being passed that increases confusion or cost?
- Is important context missing?
- Are memory, retrieval, summarization, compaction, or conversation history policies well designed?
- Is long-context handling explicit and robust?
- Are tool outputs, prior decisions, and retrieved documents incorporated in a controlled way?
- Is context isolated appropriately across subtasks, branches, or sub-agents?

5. Orchestration and autonomy
- Is the agent architecture appropriately simple, or is it over-agentized?
- Does the system use multiple agents only where specialization or decomposition is actually useful?
- Does the agent have enough autonomy to complete tasks without unnecessary user handholding?
- Does it also have appropriate boundaries before taking irreversible or high-risk actions?
- Are retries, verification steps, fallback paths, and termination conditions explicit?
- Does the workflow reduce or amplify the chance of LLM confusion, loops, or contradictory state?

6. Model strategy and platform hygiene
- Are the chosen models appropriate for the task, latency, cost, and risk profile?
- Is the repo relying on outdated, deprecated, or weak model/API choices?
- Are model-specific assumptions hardcoded in prompts or parsers?
- Is there a clear policy for upgrading model versions and validating regressions?
- Are reasoning settings, structured outputs, tool calling, and current platform capabilities used appropriately?

7. Guardrails, safety, and failure handling
- Are there input guardrails, output guardrails, and action guardrails where needed?
- Are risky tool calls, side effects, or external actions gated appropriately?
- Are there checks for hallucinations, unsupported claims, invalid tool usage, or policy violations?
- Are errors surfaced clearly to the user and to developers?
- Is there any place where the agent may act confidently without sufficient grounding?

8. Evals, observability, and production readiness
- Does the repo include agent evals, test cases, regression checks, or replayable scenarios?
- Are there traces, logs, or metrics that make agent failures diagnosable?
- Are prompts versioned and linked to runtime traces?
- Can a developer understand why the agent made a decision or used a tool?
- Is there enough instrumentation to improve the agent systematically over time?

9. Maintainability for future humans and AI agents
- Will future contributors understand how the agent is supposed to behave?
- Are prompts, tools, schemas, policies, and orchestration logic colocated and discoverable?
- Are there duplicated prompts, magic strings, hidden conventions, or scattered behavioral logic?
- Is the agent easy to modify safely without breaking hidden assumptions?

Deliverable format:

Start with:
- What’s good

Then provide:
- What should improve

For each issue include:
- severity
- category
- why it matters
- concrete evidence from the repo
- likely failure mode
- recommended fix
- expected impact

Use the following categories when relevant:
- Prompt clarity
- Prompt contradiction
- Tool definition
- Tool behavior
- Schema / typing
- Context engineering
- Memory / retrieval
- Orchestration
- Autonomy
- Model strategy
- Guardrails
- Evals / observability
- Maintainability

Explicitly call out:
- contradictory or ambiguous prompts
- unclear or weak tool descriptions
- bad tool interfaces or schema design
- fragile parsing or formatting assumptions
- outdated or deprecated model/API usage
- missing guardrails
- poor context management
- unnecessary multi-agent complexity
- places where the agent lacks autonomy
- places where the agent has too much unsafe autonomy
- missing evals, traces, or prompt versioning

End with:
- Top 5 highest-leverage agent improvements
- Quick wins under 1 hour
- Structural fixes that require design changes
- Suggested execution order

Guiding principles:
Prefer simple and explicit agent designs over clever ones.
Prefer structured contracts over natural-language conventions.
Prefer well-specified tools over prompt-only workarounds.
Prefer context discipline over dumping more tokens.
Prefer eval-driven changes over intuition.
Ground every recommendation in the actual repository, not generic agent best practices.