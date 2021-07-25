# {{{ 1 plugins
plugins=(
"$XDG_CONFIG_HOME/zsh/zsh.d/zsh-completions/zsh-completions.plugin.zsh"
"$XDG_CONFIG_HOME/zsh/zsh.d/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"
"/usr/share/fzf/key-bindings.zsh"
)
for plg in $plugins; do
    test -f "$plg" && source "$plg"
done
# }}}
# {{{ setopts
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP
setopt sharehistory
setopt appendhistory 
setopt autocd 
setopt extendedglob 
setopt prompt_subst
# }}}
# autoload{{{
autoload -U promptinit && promptinit
autoload -U colors && colors
autoload -U compinit
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
compinit -i -d "${ZSH_COMPDUMP}"

autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
# }}}
# Vars{{{
HISTSIZE=1000000
SAVEHIST=1000000
PROMPT_COMMAND="history -a; history -n"
HISTORY_IGNORE="(ls|ls -lah|cd|pwd|exit|cd ..|..)"
HISTFILE=~/.local/share/zsh/history

HELPDIR=~/.config/zsh/zsh_help
export KEYTIMEOUT=1                     # For vim status line
# }}}
# {{{ stty
stty ixany 
stty ixoff -ixon
# }}}
#{{{ Bindkey
bindkey -v

bindkey '^K' history-substring-search-up
bindkey '^J' history-substring-search-down


autoload -U edit-command-line
zle -N edit-command-line
bindkey '^V' edit-command-line                   # Opens Vim to edit current command line
# bindkey '^R' history-incremental-search-backward # Perform backward search in command line history
# bindkey '^S' history-incremental-search-forward  # Perform forward search in command line history
bindkey '^P' history-search-backward             # Go back/search in history (autocomplete)
bindkey '^N' history-search-forward              # Go forward/search in history (autocomplete)


bindkey -M vicmd '^E' end-of-line
bindkey -M vicmd '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^A' beginning-of-line
bindkey '^w' backward-kill-word
# bindkey '^?' backward-delete-char
# bindkey '^h' backward-delete-char
# bindkey '^P' run-help

# }}}
# Prompt{{{
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[red]%} [% %{$fg_bold[green]%}NORMAL%{$fg_bold[red]%}]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$EPS1"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
ZSH_THEME_GIT_PROMPT_DIRTY="*"

PROMPT='%{$fg_bold[red]%}λ %{$fg[green]%}%c %{$fg_bold[red]%}$(git_prompt_info)» %{$reset_color%}'
if [[ -f /run/.containerenv && -f /run/.toolboxenv ]]; then
  PROMPT=$(printf "\033[35m⬢\033[0m %s" $PROMPT)
fi
# }}}
#Alias{{{
alias tmux="tmux -2 -f \"$XDG_CONFIG_HOME/tmux/tmux.conf\""
alias tmuxconf="vim ~/.tmux.conf"
alias zshrc="vim ~/.config/zsh/.zshrc && source ~/.config/zsh/.zshrc"
alias i3conf="vim ~/.config/i3/config"
alias muttrc="vim ~/.config/mutt/muttrc"
alias psg="ps aux | grep "
alias g="grep -oEi"
alias ..="cd .."
alias ls="ls --color=tty"
alias l='ls -lF'
alias la='ls -laF'
alias ip='ip -br -c'
alias home="git --work-tree=$HOME --git-dir=$HOME/.config/home.git"
compdef _git home # So we get git completion with the alias
alias pacdiff="sudo -E pacdiff"

alias mksrcinfo='makepkg --printsrcinfo > .SRCINFO'

alias yubikey-refresh='gpg-connect-agent "scd serialno" "learn --force" /bye'


alias nvim='VIMINIT="" nvim'


alias -g G='| grep'
alias -g L='| less'
alias -g T='| tail'

# alias less=$PAGER
# alias zless=$PAGER

alias auracle='auracle --color=auto'
alias as='auracle search'
alias asy='auracle sync'
alias au='auracle download'
alias aud='auracle download -r *'
alias ab='auracle buildorder *'

# pacman alias
alias pacman='pacman --color auto'
alias pacupg='sudo pacman -Syu --needed'
alias pacupg-linux='sudo pacman -Syu --needed linux linux-headers linux-lts linux-lts-headers'

#Arch aliases
alias db-update='ssh repos.archlinux.org "/community/db-update"'
alias db-remove='ssh repos.archlinux.org "/community/db-remove"'
alias db-move='ssh repos.archlinux.org "/community/db-move"'

#Misc arch aliases
# alias build="aurbuild -cs -d aur"
build(){
    aur build -fcsS -d aur
}
alias nspawn="sudo systemd-nspawn -D / -x"
# }}}
# {{{ Functions
#
tm(){
    tmux new-session -A -s "$(basename "$PWD")"
}
vimrc(){
    vim ~/.config/vim/vimrc -c "cd ~/.config/vim"
}
git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}
# }}}
# zstyle{{{
unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on succesive tab press
setopt complete_in_word
setopt always_to_end
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# }}}
# misc commands{{{
    #gpg-connect-agent updatestartuptty /bye >/dev/null
if [[ $VTE_VERSION ]]; then
    source /etc/profile.d/vte.sh
    __vte_prompt_command
fi

gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
# }}}

# vim: fdm=marker
