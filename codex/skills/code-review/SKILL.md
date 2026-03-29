# Skill: Code Review

## When to use
Use when you need a consolidated repository review from multiple engineering angles (structure, complexity, dependencies, prompts/instructions)—not a single narrow check.

## Approach
Run multiple review passes from different lenses (structure, dead code, dependencies, naming, agent instructions, etc.). Run them in parallel if your environment supports delegation; otherwise sequence them. Then produce one consolidated report.

## Context
This repo was developed partly with AI assistance. It may contain oversized files, dead code, duplicated logic, weak structure, unnecessary abstractions, overcomplicated implementations, inconsistent conventions, poor prompts or agent instructions, and cases where existing dependencies are being used inefficiently or custom code could be replaced by simpler library usage.

## Goal
Identify the highest-leverage improvements to make the codebase simpler, clearer, smaller, better organized, and easier for both humans and AI agents to modify safely.

## Review for
- repository structure and module boundaries
- oversized files and decomposition problems
- dead code, unused files, stale utilities, and unnecessary abstractions
- overengineering and avoidable complexity
- opportunities to replace custom logic with better use of existing dependencies
- duplication and inconsistent patterns
- naming, readability, and local reasoning
- prompt and agent-instruction clarity where relevant
- anything that increases the chance of AI-generated mistakes during future edits

## Output
- Start with “What’s good”
- Then provide a prioritized “What should improve” section
- For each issue include:
  - severity
  - category
  - why it matters
  - concrete evidence
  - recommended fix
  - expected impact
- Explicitly call out:
  - dead code
  - files that are too large
  - overengineered code
  - bad or inefficient library usage
  - repo organization problems
  - unclear prompts or agent instructions

End with:
- Top 5 highest-leverage refactors
- Quick wins under 1 hour
- Longer-term cleanup opportunities
- Suggested execution order

## Guiding principles
Prefer deletion over addition, simpler code over clever code, and existing dependencies over custom implementations. Ground recommendations in the actual repo, not generic best practices.
