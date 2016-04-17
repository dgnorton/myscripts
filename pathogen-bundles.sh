#!/bin/sh

# If you use Pathogen to manage vim bundles, then this script may be useful.
# It dumps a list of 'git clone ...' commands to install all the bundles
# currently installed.  That output can be saved to another script file, which
# can be used to duplicate your vim setup on another machine.

# Exit script if any command fails.
set -e

cd ${HOME}/.vim/bundle

for d in $(ls);
do
	cd $d
	git remote -v | grep fetch | awk '{ print "git clone "$2 }'
	cd ..
done
