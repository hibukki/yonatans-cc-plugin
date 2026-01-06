# quick-review

A Claude Code plugin for better coding habits.

## Features

**Auto-review commits** - When Claude commits code, an async reviewer is automatically spawned. The review comes back later with suggestions, and Claude is encouraged to fix correct comments without waiting for you.

**Comment quality check** - When Claude writes a new comment, it's reminded that redundant comments are bad and asked if this comment seems necessary. This often leads Claude to remove unnecessary comments on its own.

**Package management** - When Claude tries to add a package by editing package.json or pyproject.toml directly, it's blocked and reminded to use the command line (`npm install` or `uv add`).

**Large commit warning** - When Claude makes a commit over 100 lines, it's reminded that small, self-contained commits are preferred.

**WebFetch tip** - When Claude uses WebFetch, it's reminded that downloading the full page often works better than the filtered extraction.

**Brainstorm mode** - When you ask to "brainstorm" or "find ideas", Claude launches 3 parallel subagents with different perspectives: a pain-points analyst, a minimal-code advocate, and a battle-seasoned CTO.

**Stack recommendations** - Tips for starting new projects (Vite+React, uv for Python, etc.)

## Installation

### Option 1: Via slash commands

```bash
/plugin marketplace add hibukki/yonatans-cc-marketplace
/plugin install quick-review@yonatans-cc-marketplace
```

### Option 2: Manual (in settings.json)

Add to your `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "quick-review@yonatans-cc-marketplace": true
  },
  "extraKnownMarketplaces": {
    "yonatans-cc-marketplace": {
      "source": {
        "source": "github",
        "repo": "hibukki/yonatans-cc-marketplace"
      }
    }
  }
}
```

## Setup (for contributors)

```bash
git config core.hooksPath .githooks
```

This enables the pre-commit hook that auto-bumps the plugin version.
