# CLAUDE.md – JJ Quick Command List

A minimal cheat‑sheet of the day‑to‑day **Jujutsu (`jj`)** commands you (or an agent) really need.

| Purpose                       | Command                                | What it does                                                      |
| ----------------------------- | -------------------------------------- | ----------------------------------------------------------------- |
| **See changes**               | `jj status`                            | Show working‑copy commit and staged/unstaged file modifications   |
| **Browse history**            | `jj log`                               | One‑line graph of commits; add `-r : --git` to include Git hashes |
| **Diff current work**         | `jj diff`                              | Compare working‑copy commit to its parent (like `git diff`)       |
| **Start a new change**        | `jj new`                               | Fork a fresh change from `@` (no checkout dance)                  |
| **Write/update message**      | `jj describe -m "msg"`                 | Sets commit message of the working change                         |
| **Split hunks interactively** | `jj split`                             | Launches diff‑editor to carve current change into smaller ones    |
| **Undo last (or any) op**     | `jj undo`                              | Reverts the specified operation in the op‑log                     |
| **List operations**           | `jj op log`                            | Shows numbered operation history for quick undo/restore           |
| **Push**                      | `git push origin @` *or* `jj git push` | Uses standard Git remotes; your CI never notices                  |
| **Pull / rebase**             | `git pull --rebase`                    | JJ auto‑rebases local changes on fetch                            |
| **List branches (bookmarks)** | `jj branch list`                       | Display bookmarks pointing at changes                             |
| **Create branch**             | `jj branch create feature`             | Label current change as *feature*                                 |
| **Move branch**               | `jj branch set feature REV`            | Point bookmark *feature* at another revision                      |
| **Delete branch**             | `jj branch delete feature`             | Remove bookmark label                                             |

### Safety net

* `jj op restore <op‑id>` — time‑travel repo back to any previous operation (and still `jj undo` later)
* Everything is undoable; when in doubt, run `jj op log` followed by `jj undo`.

### Automation tips

* Pass `--no-editor` on `describe`, `split`, etc., in headless scripts.
* Prefer `--template '{id} {description|escape_json}\n'` for JSON‑friendly output.

---

For deeper dives, see the full JJ tutorial and command reference, but this page should cover 95 % of daily work.
