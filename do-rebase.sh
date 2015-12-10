#!/bin/bash -e

# Assume `base` is the 'master' branch:
# For each branch:
#    - check out branch
#    - rebase onto `base`
BASE_BRANCH=base

if test $(git rev-parse --abbrev-ref HEAD) != $BASE_BRANCH; then
    echo "Current branch not $BASE_BRANCH;" \
	"are you modifying the right branch?" >&2
    exit 1
fi

doit() {
    set -x  # Show user what we're doing

    for branch in jessie-64 jessie-32 jessie-armhf \
	wheezy-64 wheezy-32 wheezy-armhf; do

	git checkout $branch
	git rebase $BASE_BRANCH
    done
    git checkout $BASE_BRANCH
}
( doit; )

# Show user what we've done
git show-branch
git branch -vv
echo 'Now run `git push -f --all`, if desired' >&2
