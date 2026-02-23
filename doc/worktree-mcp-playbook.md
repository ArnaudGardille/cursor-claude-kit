# Worktrees + MCP setup (Cursor, Claude Code, Codex)

This is the shortest path to run all three apps in parallel without stepping on each other.

## 1) Use one branch per agent with `git worktree`

From your main clone:

```bash
# from: /path/to/project
git fetch origin

# keep main checkout clean
git switch main
git pull --ff-only

# create sibling worktrees (one per app)
git worktree add ../project-cursor -b feat/ui-cursor
git worktree add ../project-claude -b feat/ui-claude
git worktree add ../project-codex -b feat/ui-codex
```

Recommended mapping:

- Cursor -> `../project-cursor`
- Claude Code -> `../project-claude`
- Codex -> `../project-codex`

Why this helps:

- no branch/file lock conflicts between agents
- each agent can run commands and edits independently
- PRs stay small and attributable

## 2) Keep the dev loop stable

Use one app server per worktree (or one shared server if enough):

```bash
# example with explicit ports per worktree
# cursor worktree
cd ../project-cursor && npm run dev -- --port 3101

# claude worktree
cd ../project-claude && npm run dev -- --port 3102

# codex worktree
cd ../project-codex && npm run dev -- --port 3103
```

Recommendation:

- if you want reproducible agent checks, point Playwright flows to explicit ports
- keep one "golden" happy-path flow per app area (auth, checkout, settings)

## 3) Enable the two MCP servers that matter first

### A) Playwright MCP (browser automation)

Use this for repeatable UI checks (click/fill/assert), not just visual inspection.

Codex:

```bash
codex mcp add playwright npx "@playwright/mcp@latest"
codex mcp list
```

Claude Code:

```bash
claude mcp add playwright -- npx @playwright/mcp@latest
claude mcp list
```

Cursor:

- `Settings -> MCP -> Add new MCP Server`
- command: `npx @playwright/mcp@latest`

### B) Context7 MCP (up-to-date docs in prompt)

Use this to reduce stale/hallucinated library usage.

Codex:

```bash
# remote (recommended)
codex mcp add context7 --url https://mcp.context7.com/mcp

# optional local variant
# codex mcp add context7 npx -y @upstash/context7-mcp
```

Claude Code:

```bash
# remote
claude mcp add context7 --url https://mcp.context7.com/mcp
```

Cursor:

- `Settings -> Cursor Settings -> MCP -> Add new global MCP server`
- url: `https://mcp.context7.com/mcp`

Optional rule (good default in all 3 tools):

- "Use Context7 for library/API docs, setup, and config questions."

## 4) Marketplace guidance (short version)

- Cursor: use marketplace mostly for editor UX (themes/extensions); use MCP for agent capabilities.
- Claude Code: plugin marketplaces are useful for packaging/reuse across commands, agents, hooks, skills, and MCP servers.
- Team rule: keep capability surface small. Prefer 2-4 high-trust MCP servers over many overlapping plugins.

## 5) Practical team policy (recommended)

- default stack: `Playwright MCP + Context7 MCP`
- standard loop: edit -> run MCP flow -> inspect console/snapshot -> patch -> repeat
- security: keep MCP server allowlist tight and review third-party server code before enabling org-wide

## References

- Cursor MCP docs: <https://docs.cursor.com/en/context/mcp>
- Claude Code MCP docs: <https://docs.anthropic.com/en/docs/claude-code/mcp>
- Claude Code plugins docs: <https://docs.claude.com/en/docs/claude-code/plugins>
- OpenAI Codex MCP docs: <https://platform.openai.com/docs/docs-mcp>
- Playwright MCP: <https://github.com/microsoft/playwright-mcp>
- Context7 MCP: <https://github.com/upstash/context7>
