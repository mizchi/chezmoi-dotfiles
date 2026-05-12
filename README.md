# chezmoi-dotfiles

macOS dotfiles split across **nix home-manager** (packages / `programs.*`) and **chezmoi** (per-user dotfile content), with **APM** layering Claude Code skills on top.

## Responsibility split

| Layer | Owns | Source of truth |
|---|---|---|
| **nix home-manager** | CLI packages (`pkgs.*`), `programs.*` wrappers (git / direnv / zsh / etc), `pkfire` / `pkl` / `actionlint` and the rest of the brew → nix Tier-3 migration | `dot_config/home-manager/flake.nix` + `common.nix` |
| **nix-darwin** | macOS system layer + the Homebrew prefix at `~/brew` (pinned by `nix-darwin`'s `homebrew` module) | `dot_config/home-manager/darwin.nix` |
| **chezmoi** | `~/.claude/`, `~/.codex/`, `~/.apm/`, `~/.config/<editor-or-shell>`, `~/.zshrc`, anything `programs.*` can't shape | `dot_*` / `private_dot_*` sources at this repo's root |
| **APM** | Public Claude Code skills (`~/.claude/skills/<name>/`) listed in `~/.apm/apm.yml` | `apm install -g` deploys; chezmoi explicitly **ignores** these paths via `.chezmoiignore` |
| **Local-only skills** | Private skills not safe for public repos (`npm-release`, `chloe-chat`) | Lives outside chezmoi-managed tree; loaded as symlinks |

Two principles keep this from collapsing:

1. **A file is owned by exactly one layer.** If home-manager owns a package, chezmoi must not also try to install / pin it. `.chezmoiignore` enforces the boundary against APM-managed skill paths.
2. **Install order: nix → chezmoi → apm.** brew prefix is set up by `run_once_before_install-brew.sh` so `nix-darwin`'s `homebrew` module can reference it; `chezmoi apply` then deploys everything else; `apm install -g` lays down the public Claude Code skills last.

## First-run install

```bash
# 0. Install Nix (Determinate Systems installer recommended).
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 1. Bootstrap chezmoi.
chezmoi init https://github.com/mizchi/chezmoi-dotfiles.git
chezmoi apply   # runs run_once_before_install-brew.sh on first apply

# 2. Switch home-manager / nix-darwin.
#    Standalone home-manager (no system-layer changes):
nix run home-manager/master -- switch --flake ~/.config/home-manager#macos
#    OR full system + home-manager via nix-darwin:
nix run nix-darwin -- switch --flake ~/.config/home-manager#macos

# 3. Deploy Claude Code skills from APM.
apm install -g --update
```

After step 2, every `home.packages` entry from `common.nix` (`pkfire`, `ripgrep`, `ast-grep`, `awscli2`, …) is on `PATH`.

## Updating

| Change | Edit | Apply |
|---|---|---|
| Add a CLI package | `dot_config/home-manager/common.nix` (`home.packages`) | `darwin-rebuild switch --flake .#macos` (or `home-manager switch`) |
| Add a third-party flake input (e.g. `pkfire`) | `dot_config/home-manager/flake.nix` (`inputs` + `sharedOverlays`) | `nix flake update` + switch |
| Edit a dotfile (`~/.claude/CLAUDE.md`, `~/.zshrc`, …) | `dot_<path>/...` in this repo (chezmoi source) | `chezmoi apply` |
| Add / remove a Claude Code skill | `dot_apm/apm.yml` → `chezmoi apply` → `apm install -g --update` | both, in that order |
| Update prompts inside `~/.claude/skills/<apm-managed>/` | edit upstream skill repo, `apm install -g --update` | apm only — chezmoi must not touch these paths |

The `programs.git`, `programs.direnv`, `programs.zsh` etc. inside `common.nix` shape the dotfiles those tools read directly, so don't also stage them via chezmoi. When in doubt: if a `programs.*` wrapper exists in home-manager, use it; otherwise chezmoi.

## Pre-push (secretlint)

This repo is protected by **`pkfire` + `secretlint`** — the hook fires on `git push`, scoped to the diff range about to leave the machine. CLAUDE.md mandates the same hook in every new mizchi-owned repo.

```bash
pkf hooks install   # one-time per checkout — writes .git/hooks/pre-push
```

The actual gate lives in `Taskfile.pkl` (a `pre-push` task that depends on `secretlint`). `secretlint` itself comes from npm devDependencies (`secretlint` ^9 + `@secretlint/secretlint-rule-preset-recommend` ^9), configured by `.secretlintrc.json`. Emergency bypass: `git push --no-verify`.

Rationale for **pre-push and not pre-commit**: secretlint is fast but not free, and re-running it on every micro-commit during a feature branch is wasted attention. The gate that matters is the one between your local repo and the public registry — that's pre-push.

## Skill-related operations

For day-to-day chezmoi operations (diff, apply, adding a new file, the boundary between chezmoi-tracked and APM-managed skills, pkfire + secretlint), see the `chezmoi-management` skill at [`mizchi/skills/chezmoi-management`](https://github.com/mizchi/skills/tree/main/chezmoi-management). That skill is the operations guide; this README is the architecture summary.
