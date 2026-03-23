# ---- Global definitions (if present) ----
if [[ -f /etc/zshrc ]]; then
  source /etc/zshrc
fi

CUSTOM_DEF="$HOME/.shell_env"
CUSTOM_SSH="$HOME/.shell_ssh"

# ---- Custom definitions ----
if [[ -f "$CUSTOM_DEF" ]]; then
  source "$CUSTOM_DEF"
else
  echo "! Missing custom bash environment variables in $CUSTOM_DEF"
fi

if [[ -f "$CUSTOM_SSH" ]]; then
  source "$CUSTOM_SSH"
else
  echo "! Missing custom ssh configuration in $CUSTOM_SSH"
fi

# ---- PATH handling (zsh-idiomatic) ----
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)
export PATH

# Uncomment if you don't like systemctl's auto-paging
# export SYSTEMD_PAGER=

# ---- Per-file aliases / functions ----
if [[ -d "$HOME/.bashrc.d" ]]; then
  for rc in "$HOME/.bashrc.d/"*; do
    [[ -f "$rc" ]] && source "$rc"
  done
fi
unset rc

# ---- Rust ----
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ---- GHCup ----
[[ -f "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"

# ---- fnm (Node) ----
FNM_PATH="$HOME/.local/share/fnm"
if [[ -d "$FNM_PATH" ]]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env)"
fi

# ---- OCaml ----
eval "$(opam env)"

# ---- Starship ----
eval "$(starship init zsh)"
