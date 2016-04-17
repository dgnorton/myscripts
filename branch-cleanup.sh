#!/bin/sh

set -e

if [ -z "$1" ]; then
	printf "\nusage: branch-cleanup.sh <git username>\n\n"
	printf "Deletes all merged branches and branches with no unmerged commits by the specified user.\n\n"
	exit 1
fi

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

GITUSER="$1"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
ALLBRANCHES="$CURRENT_BRANCH $(git branch -l | grep -v master | grep -v $CURRENT_BRANCH)"

if [ -z "$ALLBRANCHES" ]; then
	printf "no branches found\n"
	exit 0
fi

printf "\n%-25s %-8s %-7s\n" " " "unmerged" " "
printf "%-25s %-8s %-7s\n" "branch" "commits" "deleted"
printf "%-25s %-8s %-7s\n" "-------------------------" "--------" "-------"

for BRANCH in $ALLBRANCHES; do
	UNMERGED=$(git log master..${BRANCH} | grep $GITUSER | wc -l)

	if [ "$UNMERGED" -gt "0" ]; then
		printf "${RED}  %-25s${NORMAL} %-8i %-7s\n" "$BRANCH" "$UNMERGED" " "
	elif [ "$BRANCH" = "$CURRENT_BRANCH" ]; then
		printf "* ${RED}%-25s${NORMAL} %-8i %-7s\n" "$BRANCH" "$UNMERGED" " "
	else
		printf "${GREEN}  %-25s${NORMAL} %-8i %-7s\n" "$BRANCH" "$UNMERGED" "X"
		git branch -q -D $BRANCH
	fi
done

printf "\n${RED}red${NORMAL} = not deleted; ${GREEN}green${NORMAL} = deleted; * = current branch (can't delete)\n\n"
