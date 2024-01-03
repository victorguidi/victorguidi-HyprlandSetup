#!/bin/bash

TASK_DIR="$HOME/.task"

commit_changes() {
    cd "$TASK_DIR" || exit
    git add .
    git commit -m "task from $(date +%Y-%m-%d)"
    git push origin master
}

pull_changes() {
    cd "$TASK_DIR" || exit
    git pull origin master
}

# Check if the first argument is "commit" or "pull"
if [ "$1" == "commit" ]; then
    commit_changes
elif [ "$1" == "pull" ]; then
    pull_changes
else
    echo "Usage: $0 [commit|pull]"
    exit 1
fi

