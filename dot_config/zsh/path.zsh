# PATH settings
typeset -U path  # Remove duplicates

path=(
  $HOME/.local/bin
  $HOME/brew/bin
  $HOME/.cargo/bin
  $HOME/bin
  $HOME/.deno/bin
  $HOME/.bun/bin
  $HOME/.moon/bin
  $HOME/.amp/bin
  $HOME/.wasmtime/bin
  $HOME/.antigravity/antigravity/bin
  $HOME/.opencode/bin
  $HOME/ghq/github.com/apple/container/bin
  $path
)

export PATH
