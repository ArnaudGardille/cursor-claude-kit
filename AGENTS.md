# AGENTS.md

This repository is a **configuration kit** for agent-assisted development across Cursor, Claude Code, and OpenAI Codex.

It is not an application runtime. Most changes here are policy, workflow, and template changes that downstream repos will copy or symlink.

## Mission

When editing this repo, optimize for:
- Strong defaults that prevent high-risk behavior.
- Minimal, reviewable diffs.
- Cross-tool parity (Cursor / Claude / Codex should not drift on core safety and quality expectations).
- Practical guidance that teams can adopt quickly.

## Repo Map

- `README.md`: canonical overview and adoption instructions.
- `doc/worktree-mcp-playbook.md`: worktree + MCP setup guidance.
- `cursor/`: templates for `.cursor/`.
- `cursor/rules/*.mdc`: persistent Cursor rules.
- `cursor/agents/*.md`: Cursor subagents.
- `cursor/skills/*.md`: Cursor skills.
- `cursor/hooks.json`: hook wiring.
- `cursor/hooks/block-destructive.sh`: command safety enforcement.
- `claude/CLAUDE.md`: Claude Code policy template.
- `claude/CLAUDE.example.md`: detailed project-specific example.
- `claude/settings.json`: Claude permissions/rules template.
- `claude/agents/`, `claude/skills/`: Claude subagents and skills.
- `codex/AGENTS.md`: Codex template to copy to repo root in downstream projects.
- `codex/skills/`: Codex skills.

## Ground Rules

- Keep changes focused: no ornamental refactors or broad rewrites.
- Preserve tone and intent: this kit is intentionally opinionated, practical, and safety-first.
- Prefer editing existing files over creating new docs unless explicitly required.
- Do not add stack-specific runtime instructions unless they are true for this repo.
- If information is not derivable from the repo, state uncertainty instead of guessing.

## Cross-Tool Parity Policy

When changing shared policy areas, update all relevant surfaces in the same PR.

- Safety policy change:
  - `cursor/rules/00-safety.mdc`
  - `claude/CLAUDE.md`
  - `codex/AGENTS.md`
  - Hook/permissions enforcement when applicable:
    - `cursor/hooks/block-destructive.sh`
    - `cursor/hooks.json`
    - `claude/settings.json`

- Testing/quality policy change:
  - Corresponding Cursor rules (`10-*`, `11-*`, `12-*`, etc.)
  - `claude/CLAUDE.md`
  - `codex/AGENTS.md`

- Eval workflow change:
  - Cursor and Claude Eval Doctor definitions
  - `codex/skills/eval-doctor/SKILL.md`
  - Relevant README sections

If parity is intentionally not preserved, document why in the PR notes.

## Definition Of Done

A change is complete only when:
- The requested behavior/content update is implemented.
- The diff is minimal and scoped to the request.
- Relevant validation commands were run and results were checked.
- README and templates stay consistent when behavior changed.

## Validation Commands For This Repo

Run what is relevant to your edit set.

- JSON validity:
  - `jq empty cursor/hooks.json claude/settings.json .claude/settings.local.json`
- Shell syntax:
  - `bash -n cursor/hooks/block-destructive.sh`
- Markdown file presence and basic structure sanity:
  - `rg --files README.md AGENTS.md cursor/AGENTS.md claude/CLAUDE.md codex/AGENTS.md`
- Inspect exactly what changed:
  - `git diff -- README.md AGENTS.md cursor/ claude/ codex/ doc/`

If a command cannot run in the current environment, say so explicitly and provide the closest equivalent check you did.

## Safety Model

Safety guidance in markdown is necessary but not sufficient. Enforcement must exist in executable controls.

- Policy layer:
  - Cursor rules
  - `claude/CLAUDE.md`
  - Codex `AGENTS.md`
- Enforcement layer:
  - Cursor hooks (`cursor/hooks.json`, `cursor/hooks/block-destructive.sh`)
  - Claude permissions (`claude/settings.json`)

For destructive operations (data deletion, infrastructure destruction, forceful cleanup):
- Default stance is deny.
- Require explicit migration + rollback + staged validation plan.
- Require explicit human confirmation before execution.

## Contribution Playbooks

### Adding or editing a Cursor rule

1. Update the correct file in `cursor/rules/`.
2. Keep scope tight with clear frontmatter and globs.
3. Mirror equivalent policy updates in Claude/Codex templates.
4. Update README only if user-facing behavior/adoption changes.

### Adding or editing a subagent

1. Keep one responsibility per agent (Verifier, Eval Doctor, etc.).
2. Make trigger conditions and output format explicit.
3. Ensure role complements rules/skills rather than duplicating them.
4. Reflect notable behavior changes in README if needed.

### Adding or editing a skill

1. Keep it deterministic and procedural.
2. Prefer short loops with clear stop conditions.
3. Explicitly state what the skill must not do.
4. Ensure examples and commands are runnable.

### Editing adoption instructions

1. Verify copy/symlink commands and paths exactly match current repo layout.
2. Keep examples portable (relative paths for project setup, absolute only for local-global examples).
3. Re-check the three tool sections (Cursor, Claude, Codex) for consistency.

## What To Avoid

- Do not introduce fake placeholder commands (for example `pytest`, `ruff`, `mypy`) unless they are actually part of this repo’s own validation path.
- Do not claim enforcement if only prose changed.
- Do not silently weaken destructive-command protections.
- Do not bloat templates with generic advice not tied to the kit’s purpose.

## Recommended Change Summary Format

When finishing a task in this repo, report:
- Files changed.
- Why each change was needed.
- Validation commands run and outcomes.
- Any intentional parity gaps across Cursor/Claude/Codex.

This keeps downstream adopters confident that kit updates are safe to pull in.
