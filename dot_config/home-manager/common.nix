{ pkgs, lib, ... }:

{
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # 注: direnv の doCheck=false は flake.nix の sharedOverlays で global に
  # 当てている（nix-darwin 経由のときに common.nix 側 overlay が ignore される
  # ため、flake-level で一元管理する形に集約済み）

  home.packages = with pkgs; [
    # 開発系の中核 CLI（programs.* wrapper を使わないもの）
    ripgrep
    fd
    just
    ast-grep
    jq
    hyperfine
    difftastic

    # bulk migration from brew (Tier 3)
    actionlint
    aws-vault
    awscli2
    buf
    duckdb
    ghq
    git-filter-repo
    hey
    k6
    mercurial
    podman
    colima
    lima
    protobuf
    shellcheck
    sqlc
    stripe-cli
    swiftlint
    tig
    tree-sitter
    viu
    websocat
    wget
    xcodegen
    zig
    gnupg
    go            # brew autoremove で消えたので復元
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    HELIX_RUNTIME = "$HOME/ghq/github.com/helix-editor/helix/runtime";
    HOMEBREW_FORBIDDEN_FORMULAE = "node python python3 pip npm pnpm yarn claude";
    BUN_INSTALL = "$HOME/.bun";
    WASMTIME_HOME = "$HOME/.wasmtime";
    CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
    DIRENV_LOG_FORMAT = "";
  };

  home.sessionPath = [
    # nix-darwin + home-manager の useUserPackages=true 経路で user packages
    # の実体が置かれる場所（旧 ~/.nix-profile/bin はもう使わない）
    "/etc/profiles/per-user/mz/bin"
    "$HOME/.nix-profile/bin"
    "$HOME/.local/bin"
    "$HOME/brew/bin"
    "$HOME/.cargo/bin"
    "$HOME/bin"
    "$HOME/.deno/bin"
    "$HOME/.bun/bin"
    "$HOME/.moon/bin"
    "$HOME/.amp/bin"
    "$HOME/.wasmtime/bin"
    "$HOME/.antigravity/antigravity/bin"
    "$HOME/.opencode/bin"
    "$HOME/ghq/github.com/apple/container/bin"
    "$HOME/.mooninstall/bin"
    "$HOME/.duckdb/cli/latest/duckdb"
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = { format = "[\\$](green bold) "; };
      directory = { truncation_length = 3; };
      git_branch = {
        symbol = "";
        format = ''\([$symbol$branch(:$remote_branch)]($style)\)'';
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "";
        ahead = "";
        behind = "";
        diverged = "";
        up_to_date = "✓";
        untracked = "";
        stashed = "";
        modified = "🔥";
        staged = "";
        renamed = "";
        deleted = "";
      };
      package = { disabled = true; };
      nodejs = { disabled = true; };
      gcloud = { disabled = true; };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    # direnv 2.37.1 は DIRENV_LOG_FORMAT 環境変数を無視するので、
    # direnv.toml の global.log_format で起動時の "loading / using / export" を抑制する。
    config.global.log_format = "";
    # 注: direnv の doCheck は上の nixpkgs.overlays で global に切ってある
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Tier 2: programs.* wrapper 経由で管理（package + 設定が一括でつく）
  # zsh integration は手書き shellAliases と被るため、必要時だけ enable
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };
  programs.tmux.enable = true;
  programs.lazygit.enable = true;
  programs.btop.enable = true;
  programs.yazi.enable = true;

  programs.helix = {
    enable = true;
    settings = {
      theme = "darcula-solid";
      editor = {
        mouse = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker = { hidden = false; };
        indent-guides = { render = true; };
      };
      keys.normal = {
        "Cmd-s" = ":write";
        "Cmd-C-r" = [ ":write" ":config-reload" ];
        space = { q = ":q"; };
      };
      keys.insert = {
        "C-b" = "move_char_left";
        "C-e" = "goto_line_end_newline";
        "C-a" = "goto_line_start";
        "C-f" = "move_char_right";
        "S-right" = "extend_char_right";
        "S-left" = "extend_char_left";
        "S-up" = "extend_line_up";
        "S-down" = "extend_line_down";
        "Cmd-c" = "yank_to_clipboard";
        "C-right" = "move_next_word_start";
        "C-left" = "move_prev_word_end";
        "C-S-right" = "extend_next_word_start";
        "C-S-left" = "extend_prev_word_end";
      };
    };
    # languages.toml はローカル fork パスを含むため chezmoi 管理に残す
    # (~/.config/helix/languages.toml は引き続き chezmoi が source-of-truth)
  };

  programs.sheldon = {
    enable = true;
    settings = {
      shell = "zsh";
      plugins = {
        zsh-autosuggestions = { github = "zsh-users/zsh-autosuggestions"; };
        fast-syntax-highlighting = { github = "zdharma/fast-syntax-highlighting"; };
        ni = { github = "azu/ni.zsh"; };
      };
    };
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "24";
        pnpm = "latest";
      };
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    ignores = [
      "**/.claude/settings.local.json"
      ".mizchi/**"
      ".local/**"
      "mise.local.toml"
      ".mise.local.toml"
      "apm_modules/"
      ".frontend-review/"
    ];
    settings = {
      # user.name / user.email は flake.nix で private.nix から注入
      alias = {
        s = "status";
        co = "commit";
      };
      init.defaultBranch = "main";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
        external = "difft";
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      pull.rebase = true;
      help.autocorrect = "prompt";
      commit.verbose = true;
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      protocol.file.allow = "always";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;
    enableCompletion = true;

    shellAliases = {
      la = "eza -a --git -g -h --oneline";
      ls = "eza";
      h = "hx";
      j = "just";
    };

    history = {
      path = "$HOME/.zsh_history";
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    initContent = ''
      setopt auto_pushd
      setopt auto_cd

      zstyle ':completion:*' menu select
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

      fpath=($HOME/.zsh/completions $fpath)
      fpath+=~/.zfunc

      [[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"
      [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
      [[ -f "$HOME/.vite-plus/env" ]] && . "$HOME/.vite-plus/env"

      if command -v bit >/dev/null 2>&1; then
        eval "$(bit completion zsh)"
        compdef _bit bit
      fi

      ghq() {
        if [ $# -eq 0 ]; then
          local repo_path
          repo_path=$(command ghq list | fzf --height 40% --reverse)
          if [[ -n "$repo_path" ]]; then
            cd "$(command ghq root)/$repo_path"
          fi
        else
          command ghq "$@"
        fi
      }

      ghq-fzf_change_directory() {
        local src=$(command ghq list | fzf --preview "eza -l -g -a --icons $(command ghq root)/{} | tail -n+4 | awk '{print \$6\"/\"\$8\" \"\$9 \" \" \$10}'")
        if [ -n "$src" ]; then
          BUFFER="cd $(command ghq root)/$src"
          zle accept-line
        fi
        zle -R -c
      }
      zle -N ghq-fzf_change_directory
      bindkey '^f' ghq-fzf_change_directory
    '';
  };
}
