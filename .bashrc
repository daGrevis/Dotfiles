#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=always'
alias less='less -R'
alias cl='clear'
PS1='[\u@\h \W]\$ '

source /etc/profile
source /usr/share/git/completion/git-completion.bash

complete -cf sudo
