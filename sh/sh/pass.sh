#!/usr/bin/env bash

# https://www.passwordstore.org/
alias pwl='pass list'
alias pws='pass show'
alias pwe='pass edit'
alias pwi='pass insert -m'

pwc() {
  pass show "$1" | pbcopy
}
