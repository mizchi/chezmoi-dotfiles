# Secrets (sops-nix)

Secret management for this nix-darwin + home-manager config. Replaces the old
`private.nix` env approach, which baked plaintext into the world-readable nix
store (`activation-script.drv`).

## What lives in this (public) repo vs. what does not

This repo is **public**. Only non-secret material is committed:

- `.sops.yaml` — age **public** recipient(s). Public keys, safe to publish.
- `secrets/*.json` — sops **ciphertext**. Encrypted, safe to publish.
- `secrets.nix`, `common.nix` — declarations and **paths** only, never values.

The **decryption key is never in the repo**: it is the SSH ed25519 private key
(`~/.ssh/id_ed25519`), converted to an age key on the fly via `ssh-to-age`
(`sops.age.sshKeyPaths`). It stays machine-local and travels by a separate
channel (see "New machine" below). No dedicated age key is created.

## Layers

| Layer | File | Scope | Delivery |
|-------|------|-------|----------|
| 1 — global personal | `secrets/global.json` (`MNEMO_*`) | available in every shell | declared in `secrets.nix`; sops-nix decrypts at activation to `~/.config/sops-nix/secrets/<name>` (mode 0400, outside the nix store); `common.nix` zsh init reads each `$(<path)` and exports it |
| 2 — project / billing | `secrets/personal.json` (`SAKANA_API_KEY`) | only inside the repo that uses it | intended for per-repo direnv: `.envrc` runs `sops -d --extract` (not wired yet) |

Decision rule for a new key: *do I want it in every shell unconditionally, or
only while working in one repo?* When in doubt, prefer layer 2 (narrower scope).

## Add a layer-1 secret

```sh
cd ~/.config/home-manager
sops secrets/global.json          # editor opens decrypted; save re-encrypts
# add `sops.secrets.<NAME> = {};` to secrets.nix
darwin-rebuild switch --flake .#macos
```

The zsh export loop in `common.nix` is generated from
`config.sops.secrets`, so a new name is picked up automatically — only the
**path** is baked into `.zshrc`, never the value.

## New machine

The private key is never put in the repo. Preferred flow adds the new
machine's own key as a recipient, so no private key is ever transported:

```sh
# on the new machine
chezmoi init <this-dotfiles-repo>          # brings ciphertext + config
ssh-keygen -t ed25519                       # if it has no key yet
ssh-to-age -i ~/.ssh/id_ed25519.pub         # -> age1... public key

# add that age public key to .sops.yaml `keys:`, then on a machine that
# already holds a key:
sops updatekeys secrets/global.json secrets/personal.json   # re-encrypt to all recipients
# commit + push, then on the new machine:
chezmoi apply && darwin-rebuild switch --flake ~/.config/home-manager#macos
```

To revoke a lost machine: drop its recipient from `.sops.yaml`, run
`sops updatekeys`, commit. (Rotate the secret values too if the machine may
have been compromised.)

Alternatively (single-key) copy `~/.ssh/id_ed25519` to the new machine out of
band (e.g. secure transfer) and skip the recipient edit — simpler, but the
private key then travels.

## Gotchas

- `nix build` runs in a sandbox that hides `~/.ssh`, so a build-time sops
  decrypt check can fail with `unexpected EOF`. Real `darwin-rebuild switch`
  decrypts at activation (outside the sandbox) and works.
- `nix flake lock` for `sops-nix` hits the GitHub API and may 403 on rate
  limit. Authenticate: `NIX_CONFIG="access-tokens = github.com=$(gh auth token)" nix flake lock`.
- The darwin `homebrew` block refuses untrusted taps mid-switch
  (`Refusing to load formula ... from untrusted tap`). Run `brew trust <tap>`
  for each before switching.
