# ghq with fzf integration
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

# ghq-fzf directory change with preview
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
