alias ls='ls --color=always'
alias less='less -R'
alias cl='clear'
alias la='ls -la --color=always'
alias l='ls -l --color=always'
alias sl=ls
alias bb="echo 'Bye-bye then!'; sudo shutdown -h now"
function search {
    echo "Searching: $1"
    find . -type f | xargs grep $1 -sl
}
