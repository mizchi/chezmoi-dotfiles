# jj (Jujutsu) Best Practices

## Core Concepts

jj automatically commits working copy changes, unlike Git. Changes are recorded when running commands like `jj status`.

- New files are tracked automatically (unless in `.gitignore`)
- No concept of "current branch"
- Bookmarks (equivalent to Git branches) are created only when needed

## Basic Workflow

```bash
# Check status
jj status
jj log

# Add commit message (changes are auto-committed)
jj describe -m "message"

# Start new change (finalize current and move on)
jj new

# Edit previous commit
jj new @-          # Move to parent
# ... edit ...
jj squash          # Merge into child
```

## GitHub PR Workflow

### Create bookmark and push

```bash
# Option 1: Auto-generated name (push-xxxx)
jj git push -c @-

# Option 2: Explicit naming
jj bookmark create feature-name -r @-
jj git push
```

### Update PR (address review comments)

```bash
# Option 1: Add commits (preserve history)
# Add new commits and push

# Option 2: Amend commits (rewrite history)
jj new @-              # Move to child of target commit
# ... fix ...
jj squash              # Merge into parent
jj git push --bookmark feature-name  # force push
```

### Sync with remote

```bash
jj git fetch
jj rebase -d main      # Rebase onto latest main
```

## Useful Commands

| Command | Description |
|---------|-------------|
| `jj log -r 'all()'` | Show all commits |
| `jj split -i` | Interactive split (like git add -p) |
| `jj squash` | Merge current changes into parent |
| `jj abandon` | Discard commit |
| `jj undo` | Undo last operation |
| `jj op log` | Show operation history |

## Conflict Resolution

Conflicts are embedded as markers in files. No need to resolve all at once.

```bash
# Create new commit with conflicts
jj new
# ... resolve ...
jj squash   # Merge resolution into original commit
```

## Notes

- `jj git push --all` pushes bookmarks only (not all revisions)
- Exclude `.jj/**` from watch in Vite/Vitest
- Resolve bookmark conflicts with `jj bookmark move <name> --to <commit>`
