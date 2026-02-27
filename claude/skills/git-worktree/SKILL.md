---
name: "git-worktree"
description: "Use git worktrees to work on a different branch without leaving the current workspace. Creates an isolated working directory for the target branch."
auto: false
---

# Skill: Git Worktree for Branch-Isolated Work

## When to use
Use when the task requires changes on a branch that is **not** the currently checked-out branch:
- You are on `main`/`master`/`develop` and the user asks for implementation work (even without specifying a branch).
- You are on a feature branch and the task targets a different branch.
- The user wants parallel work across branches without disrupting the current session.

Do **not** use when:
- The current branch is already the correct target for the changes.
- The task is read-only (inspection, review) and doesn't need a separate working tree.

## Inputs
- **Target branch** (optional) — the user may or may not specify one.
- **Base branch** (for new branches) — defaults to `main` or current HEAD.

## Procedure

### 1) Assess current state

```bash
git branch --show-current
git status --short
git worktree list
```

- If already on the correct branch → work directly, skip worktree.
- If uncommitted changes exist → warn the user before proceeding.
- If a worktree already exists for the target branch → reuse it.

### 2) Resolve the target branch

The user may or may not have specified a branch. Follow this decision tree:

**A) User specified a branch name** → use it directly. Verify it exists locally or on the remote:
```bash
git branch -a | grep -i "<branch>"
```

**B) User did NOT specify a branch** → search for an existing branch related to the task:
```bash
git fetch --prune origin
git branch -a | grep -iE "<keyword1>|<keyword2>"
```
Extract keywords from the task description (e.g., "implement the login fix" → `login`, `fix`).

- **Single match** → confirm with the user: *"I found branch `fix/login-bug` — I'll create a worktree for it. OK?"*
- **Multiple matches** → list them and ask the user to pick.
- **No matches** → propose a new branch name following the repo's convention, and confirm:
  - Detect convention from existing branches (`git branch -a`): e.g., `feature/...`, `fix/...`, `core/...`, `<ticket-prefix>/...`
  - Propose: *"No existing branch matches. I'll create `fix/login-bug` from `main`. OK?"*

**Do not proceed without a confirmed branch name.**

### 3) Determine worktree path

Convention — place worktrees as sibling directories of the main repo:

```
parent/
  repo/                      ← main checkout (current workspace)
  repo--feature-AI-129/      ← worktree
  repo--fix-login-bug/       ← another worktree
```

Sanitize the branch name for the directory: replace `/` with `-`.

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
SLUG=$(echo "<branch>" | tr '/' '-')
WT_PATH="../${REPO_NAME}--${SLUG}"
```

### 4) Create the worktree

**Existing remote branch:**
```bash
git fetch origin <branch>
git worktree add "$WT_PATH" <branch>
```

**New branch (from a base):**
```bash
git worktree add -b <new-branch> "$WT_PATH" <base>
```

### 5) Work in the worktree

All commands run with `cwd` set to the worktree's absolute path. File reads and writes use absolute paths into the worktree.

Install dependencies if the worktree is a fresh checkout (`npm install`, `pip install -r requirements.txt`, etc.).

### 6) Commit and push from the worktree

```bash
cd "$WT_PATH"
git add <files>
git commit -m "..."
git push -u origin <branch>
```

### 7) Report to the user

After completing work, tell the user:
- The worktree's absolute path.
- The branch it is checked out to.
- How to open it in a new terminal/editor for continued work.
- How to clean up when done:

```bash
git worktree remove <path>
# If the branch is merged and no longer needed:
git branch -d <branch>
```

## Cleanup

To list and prune stale worktrees:
```bash
git worktree list
git worktree prune
```

To remove a specific worktree:
```bash
git worktree remove "../repo--branch-slug"
```

## Constraints (non-negotiable)
- Never check out the same branch in two worktrees (git forbids it).
- Never remove a worktree without telling the user.
- Do not modify files in the main workspace when working through a worktree — keep contexts separate.
- For long-running work, recommend the user opens a new terminal or editor session in the worktree directory.
