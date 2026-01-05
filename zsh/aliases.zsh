# branches
alias gplb='git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D'

# stash
alias gsc='git stash clear'
