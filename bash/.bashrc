# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# to get electron apps to play nice
ELECTRON_OZONE_PLATFORM_HINT=auto

# to set up editor and visual
export EDITOR=nvim
export VISUAL=nvim

# to set up vim and nvim
alias vim='nvim'

# to set up both my own ssh and ahrefs ssh
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval `ssh-agent`
fi

is_key_added() {
    local key_path="$1"
    local key_fp
    key_fp=$(ssh-keygen -lf "$key_path.pub" | awk '{print $2}')

    ssh-add -l | awk '{print $2}' | grep -q "$key_fp"
}

safe_ssh_add() {
    local key_path="$1"
    is_key_added "$key_path" || ssh-add "$key_path"
}

add_ssh_key() {
    local key_path="$1"
    if [[ -f "$key_path" ]]; then
        if ! ssh-add -l | grep -q "$key_path"; then
            safe_ssh_add "$key_path"
        fi
    else
        echo "Warning: SSH key not found at $key_path"
    fi
}

add_ssh_key "$HOME/.ssh/id_general"
add_ssh_key "$HOME/.ssh/id_ahrefs"

. "$HOME/.cargo/env"


[ -f "/home/skybound/.ghcup/env" ] && . "/home/skybound/.ghcup/env" # ghcup-env
# fnm
FNM_PATH="/home/skybound/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
