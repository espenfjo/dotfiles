alias ls='ls --color'
alias p='ssh p'
alias stow='stow --ignore ".DS_Store"'
alias GET="lwp-request -m GET"

. .bashrc

PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH:/usr/local/share/npm/bin"
MANPATH="/usr/local/opt/coreutils/libexec/gnuman:/usr/local/share/man/:$MANPATH"
EDITOR=emacs
HISTSIZE=100000
HISTFILESIZE=100000

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
