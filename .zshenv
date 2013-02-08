alias ls='ls -a --color=always'

alias less='less -R'

alias cl='clear'

function search {
    echo "Searching: $1"
    find . -type f | xargs grep $1 -sl
}

function bb {
    echo "Shutdown scheduled. (Press Ctrl + C to terminate)"
    echo -n "Countdown... "
    for i in {10..1}
    do
        echo -n "$i "
        sleep 1
    done
    echo
    echo "Bye-bye then!"
    sudo shutdown -h now
}

alias vim='vim -p'

function vimdir {
    vim `find $1 -type f | xargs echo`
}

alias skype2='skype --dbpath=~/.Skype2'

alias rm='rm -i' # Once I accidentally deleted database file. If you think that this is "for noobs", you are just plain idiot!

alias diff='colordiff -u'

alias p='ping google.com'

alias flake8='flake8 --max-line-length=160'

alias py="bpython2"

alias gpu='git push -u origin $(current_branch)'
