# quick-review

A Claude Code plugin that auto-reviews commits and provides coding guardrails.

## Auto-Review

Every git commit spawns a background review. Results appear when Claude stops or on the next tool use.

## Hooks

| Hook | Trigger | Behavior |
|------|---------|----------|
| `check-npm-install` | Edit package.json | Blocks. Use `npm install <pkg>` instead |
| `check-uv-add` | Edit pyproject.toml | Blocks. Use `uv add <pkg>` instead |
| `check-comments` | Add comments to code | Advisory. Prefer self-documenting code |
| `warn-large-commit` | Commit >100 lines | Advisory. Prefer small commits |
| `on-web-fetch` | WebFetch tool | Tip: download page for better extraction |

## Skills

| Skill | Triggers | What it does |
|-------|----------|--------------|
| `brainstorm` | "brainstorm", "find ideas" | Launches 3 parallel subagents with different perspectives |
| `new-project-good-stacks` | Starting new projects | Stack recommendations (Vite+React, uv, etc.) |

## Commands

- `/quick-review` - Manually trigger a review

## Installation

```sh
claude --plugin-dir /path/to/quick-review
```
