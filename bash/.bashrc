# .bashrc
# the role of .bashrc has been reduced, will add all of the different sources here.
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

CUSTOM_DEF="$HOME/.bash_env"
CUSTOM_SSH="$HOME/.bash_ssh"

# Source custom definitions
if [ -f "$CUSTOM_DEF" ]; then
    . "$CUSTOM_DEF"
else
    echo "! Missing custom bash environment variables in $CUSTOM_DEF"
fi    
if [ -f "$CUSTOM_SSH" ]; then
    . "$CUSTOM_SSH"
else
    echo "! Missing custom ssh configuration in $CUSTOM_DEF"
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

. "$HOME/.cargo/env"

[ -f "/home/skybound/.ghcup/env" ] && . "/home/skybound/.ghcup/env" # ghcup-env
# fnm
FNM_PATH="/home/skybound/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
