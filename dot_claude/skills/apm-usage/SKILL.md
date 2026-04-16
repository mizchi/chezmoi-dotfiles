---
name: apm-usage
description: Use APM (Agent Package Manager) to manage agent skills and dependencies. Use when adding, removing, or updating skills in a project or globally, creating skills for a repository, or configuring apm.yml.
---

# APM (Agent Package Manager)

APM is a dependency manager for AI agent skills, instructions, prompts, and MCP servers. Think of it as npm for agent configuration.

## When this skill applies

- "add a skill to this project"
- "install skills globally"
- "create a skill for this repo"
- "set up apm.yml"
- "update agent dependencies"

## Core commands

```bash
# Install all dependencies from apm.yml
apm install

# Install a specific package
apm install owner/repo
apm install owner/repo/skills/skill-name    # subdirectory skill
apm install owner/repo#v1.0.0               # pinned version

# Global (user-scope) install → ~/.claude/skills/
apm install -g owner/repo/skills/skill-name

# Update all to latest
apm install --update        # project scope
apm install -g --update     # global scope

# Remove
apm uninstall owner/repo
apm uninstall -g owner/repo

# Inspect
apm deps list               # project deps
apm deps list -g             # global deps
apm deps tree                # dependency tree
apm deps tree -g

# Security scan
apm audit

# Dry run (preview without changes)
apm install --dry-run
```

## apm.yml manifest

```yaml
name: my-project
version: 1.0.0
dependencies:
  apm:
    # GitHub shorthand
    - owner/repo
    - owner/repo#v1.0.0                  # pinned tag
    - owner/repo/skills/skill-name       # subdirectory

    # Non-GitHub hosts
    - gitlab.com/org/repo
    - git: git@gitlab.com:org/repo.git
      path: skills/my-skill
      ref: main

    # Local path (dev only, not for -g)
    - ./packages/my-skill

  mcp:
    - io.github.github/github-mcp-server
scripts: {}
```

## Creating skills in a repository

Follow the [agentskills.io](https://agentskills.io/specification) open standard.

### Directory structure

```
my-repo/
└── skills/
    └── my-skill/
        ├── SKILL.md           # Required
        ├── scripts/           # Optional: executable code
        ├── references/        # Optional: detailed docs
        └── assets/            # Optional: templates, resources
```

### SKILL.md format

```markdown
---
name: my-skill
description: One-line description of what this skill does and when to use it.
---

# Skill body

Instructions for the AI agent. Keep under 500 lines.
Move detailed reference material to references/ directory.
```

### Frontmatter fields

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars, lowercase alphanumeric + hyphens, must match directory name |
| `description` | Yes | 1-1024 chars, describe what + when |
| `license` | No | SPDX identifier or license file reference |
| `compatibility` | No | Environment requirements (max 500 chars) |
| `metadata` | No | Arbitrary key-value pairs |

### Name validation rules

- Lowercase letters, numbers, hyphens only
- Cannot start or end with hyphen
- No consecutive hyphens (`--`)
- Must match the parent directory name

### Users install with

```bash
apm install owner/my-repo/skills/my-skill
```

## Skill patterns for library authors

### Single skill in a library repo

```
my-library/
├── skills/
│   └── my-library-guide/
│       └── SKILL.md
├── src/
└── package.json
```

### Multiple skills (monorepo)

```
my-org-skills/
├── skill-a/
│   └── SKILL.md
├── skill-b/
│   └── SKILL.md
└── skill-c/
    └── SKILL.md
```

Users install individually: `apm install owner/my-org-skills/skill-a`

## Target detection

APM auto-detects deployment targets from project structure:

| Directory exists | Target | Skills deployed to |
|-----------------|--------|-------------------|
| `.claude/` | claude | `.claude/skills/` |
| `.github/` | copilot | `.github/skills/` |
| `.cursor/` | cursor | `.cursor/skills/` (if supported) |
| `.codex/` | codex | `.agents/skills/` |

Override with `--target claude` or set `target:` in apm.yml.

## Global vs project scope

| | Project (`apm install`) | Global (`apm install -g`) |
|---|---|---|
| Manifest | `./apm.yml` | `~/.apm/apm.yml` |
| Modules | `./apm_modules/` | `~/.apm/apm_modules/` |
| Lockfile | `./apm.lock.yaml` | `~/.apm/apm.lock.yaml` |
| Deploy to | `./.claude/skills/` | `~/.claude/skills/` |
| Local `.apm/` content | Deployed | Skipped |

## Authentication

For private repos, APM resolves auth automatically:

1. `gh auth login` (GH_TOKEN) — zero-config if already logged in
2. `git credential fill` — OS keychain, SSH keys
3. `GITHUB_APM_PAT` environment variable — for CI or explicit setup

No extra configuration needed if `gh auth login` is done.

## Priority and conflict resolution

- Local skills always override dependency skills on name collision
- Dependencies processed in declaration order; first wins
- `apm install --force` overwrites local files on collision
