# chezmoi-dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Structure

```
dot_zshrc                 # ~/.zshrc
dot_config/
├── helix/                # Helix editor
├── mise/                 # mise (asdf alternative)
├── sheldon/              # zsh plugin manager
├── starship.toml         # Starship prompt
├── zellij/               # Terminal multiplexer
└── zsh/
    ├── path.zsh          # PATH settings
    ├── functions.zsh     # Shell functions (ghq/fzf)
    └── just.zsh          # just completions
dot_claude/
├── CLAUDE.md             # Claude Code instructions
├── settings.json         # Claude Code settings
└── skills/               # Claude Code skills
    ├── jj/               # Jujutsu VCS
    ├── justfile/         # just command runner
    ├── devbox/           # Nix-based dev environments
    ├── dotenvx/          # Environment variable management
    ├── moonbit-*/        # MoonBit language
    └── agentskills/      # Agent skills docs
```

## Install

```bash
chezmoi init https://github.com/mizchi/chezmoi-dotfiles.git
chezmoi apply

# Setup skills symlinks
~/.claude/skills/install.sh
```

## Pre-commit

Uses [prek](https://github.com/j178/prek) with [secretlint](https://github.com/secretlint/secretlint) to prevent committing secrets.

```bash
prek install
```
