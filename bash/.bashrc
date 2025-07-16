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
eval `ssh-agent` && ssh-add ~/.ssh/id_general && ssh-add ~/.ssh/id_ahrefs

