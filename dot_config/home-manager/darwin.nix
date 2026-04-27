{ pkgs, lib, private, ... }:

{
  # nix-darwin module schema version. Bump only when updating across breaking changes.
  system.stateVersion = 5;

  # 1 user 環境（mizchi）。homebrew や user-scoped activation はこの user を見る。
  system.primaryUser = private.username;

  # home-manager-as-darwin-module 経由のとき、home.homeDirectory を null から
  # 救うために user 宣言が必要（system.primaryUser だけだと足りない）。
  users.users.${private.username} = {
    name = private.username;
    home = "/Users/${private.username}";
  };

  # Apple Silicon 専用 build。Intel に出戻る予定はない。
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Determinate Nix が daemon と nix.conf を管理しているので、nix-darwin の Nix
  # 管理は一切オフにする。これがないと両者が /etc/nix/nix.conf や launchd を
  # 取り合って壊れる。
  nix.enable = false;

  # Touch ID で sudo を通せるようにする。
  security.pam.services.sudo_local.touchIdAuth = true;

  # /etc/zshrc は Determinate Nix 由来のものを尊重し、nix-darwin 側では何もしない。
  programs.zsh.enable = false;

  # ----------------------------------------------------------------------------
  # macOS defaults — 最初は壊れにくい範囲だけ宣言。GUI で触ってる項目は徐々に移す。
  # ----------------------------------------------------------------------------
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
      ApplePressAndHoldEnabled = false;  # 長押しで accent menu を出さない
    };
    finder = {
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
    };
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
    };
    trackpad.Clicking = true;
  };

  # ----------------------------------------------------------------------------
  # Homebrew bridge — 新マシン setup 時に brew bundle 相当を自動実行。
  # `cleanup = "none"` で list 外を消さない（最初は安全側）。タップ別の formula
  # は taps[] と brews[] の組合せで参照する。
  # ----------------------------------------------------------------------------
  homebrew = {
    enable = true;
    # mizchi の brew は単一ユーザ install で ~/brew にあり、Apple Silicon の
    # 標準 /opt/homebrew ではない。nix-darwin にその位置を教える。
    prefix = "/Users/${private.username}/brew";
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    taps = [
      "ariga/tap"
      "dotenvx/brew"
      "felixkratz/formulae"
      "k1low/tap"
      "microsoft/apm"
      "pkgxdev/made"
      "sinelaw/fresh"
    ];

    brews = [
      "abseil"
      "atlas"
      "autoconf"
      "bash"
      "bison"
      "borders"
      "cargo-binstall"
      "chafa"
      "chezmoi"
      "cmake"
      "cocoapods"
      "coreutils"
      "darcs"
      "docutils"
      "dotenvx"
      "elixir"
      "ffmpeg"
      "fresh"
      "gibo"
      "git-wt"
      "gleam"
      "glfw"
      "gnutls"
      "gobject-introspection"
      "googletest"
      "gtk+"
      "ios-deploy"
      "libgpg-error"
      "libimobiledevice"
      "libpq"
      "lua"
      "meson"
      "apm"
      "nowplaying-cli"
      "opam"
      "pkgx"
      "python-setuptools"
      "riscv64-elf-gcc"
      "rust"
      "sbt"
      "sketchybar"
      "switchaudio-osx"
      "texinfo"
      "util-macros"
      "xmlto"
      "xtrans"
    ];

    casks = [
      "aerospace"
      "amical"
      "azookey"
      "codex"
      "docker-desktop"
      "ghostty"
      "plamo-translate"
      "sbx"
      "sf-symbols"
    ];
  };
}
