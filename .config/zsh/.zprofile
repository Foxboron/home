export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

export TASKRC="$XDG_CONFIG_HOME"/task/taskrc
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export NOTMUCH_CONFIG="$XDG_CONFIG_HOME/notmuch/config"

export TASKDATA="$XDG_DATA_HOME"/task

export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"

export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/d.9mnncqwudgr47xbf99yfancp/S.gpg-agent.ssh"

# XDG Patches
export VIMINIT=":source $XDG_CONFIG_HOME/vim/vimrc"
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export RANDFILE="$XDG_RUNTIME_DIR/rnd"

export GOPATH="$HOME/.go"
export LC_ALL=en_US.utf8
export LANG=en_US.utf8
export TERM="xterm-256color"
export EDITOR="vim"
export TERMINAL=termite
export BROWSER=/home/fox/bin/open.sh

if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec startx "$XDG_CONFIG_HOME/X11/xinitrc" -- vt1
fi
