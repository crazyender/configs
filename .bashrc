# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=


# User specific aliases and functions
alias ls="ls --color=auto"
alias l="ls -l"
alias ll="ls -al"
alias cls="clear"
alias fzf="fzf --multi --preview='head -50 {+}'"
export GIT_SSH_COMMAND='ssh -oHostKeyAlgorithms=+ssh-dss'
export PKG_CONFIG_PATH=/usr/local/share/pkgconfig
export COVFILE=~/test.cov
stty -ixon
# User specific environment and startup programs

function __promp_command(){
	local EXIT="$?"
	local RCol='\[\e[0m\]'
    	local Red='\[\e[0;31m\]'
    	local Gre='\[\e[0;32m\]'
	local Branch=""
	if [ -d .git ]; then
                Branch="($(git symbolic-ref --short -q HEAD))"
        else
                Branch=""
        fi

	PS1="\[\e[32m\]\u@\h\[\e[m\] \[\e[33m\]$ \w ${Branch}\[\e[m\]\n"

	if [ $EXIT != 0 ]; then
		PS1+="${Red}\$${RCol} "
	else
		PS1+="${Gre}\$${RCol} "
	fi
}

PROMPT_COMMAND=__promp_command

function missing(){
	if [ -d $1 ]; then
		find "$1" -name '*.so' -type f -print | xargs ldd | grep 'not found'
	else
		ldd $1 | grep 'not found'
	fi
}

function depends(){
	if [ -d $1 ]; then
                find "$1" -name '*.so' -type f -print | xargs ldd
        else
                ldd $1
        fi

}

alias lock="xscreensaver-command -lock"
export TERM="screen-256color"
export POWERLINE_BASH_CONTINUATION=1
export POWERLINE_BASH_SELECT=1
