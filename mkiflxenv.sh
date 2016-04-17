#!/bin/bash

goGetVimGoDeps() {
	# GOPATH where vim-go binaries are cached.
	VIMGOPATH="$GOPATH/../../vimgo"

	# If vim-go cache exists, copy binaries from there.
	if [ -d "$VIMGOPATH" ]; then
		echo "using vim-go cache: $VIMGOPATH/go/bin"
		cp -r $VIMGOPATH/go/bin/* $GOPATH/bin
		return
	fi

	# Create cache of vim-go binaries.
	echo "creating vim-go cache: $VIMGOPATH/go/bin"
	ORIGDIR="$(pwd)"
	mkdir -p $VIMGOPATH && cd $VIMGOPATH && mkgoenv.sh && cd go
	. goenv.sh

	set -x
	go get -u github.com/nsf/gocode
	go get -u github.com/alecthomas/gometalinter
	go get -u golang.org/x/tools/cmd/goimports
	go get -u github.com/rogpeppe/godef
	go get -u golang.org/x/tools/cmd/oracle
	go get -u golang.org/x/tools/cmd/gorename
	go get -u github.com/golang/lint/golint
	go get -u github.com/kisielk/errcheck
	go get -u github.com/jstemmer/gotags
	go get -u github.com/klauspost/asmfmt/cmd/asmfmt
	go get -u github.com/fatih/motion
	set +x

	# Restore the original GOPATH.
	cd $ORIGDIR
	. goenv.sh

	# Copy vim-go binaries from the newly created cache.
	echo "using vim-go cache: $VIMGOPATH/go/bin"
	cp -r $VIMGOPATH/go/bin/* $GOPATH/bin
}

goGetUtilDeps() {
	set -x
	go get -u github.com/davecgh/go-spew/spew
	set +x
}

setupProject() {
	if [ -d "$1" ]; then
		echo "directory $1 already exists"
		exit 1
	fi

	mkdir -p $1/go/bin $1/go/pkg $1/go/src/github.com/influxdata
	cd $1/go/src/github.com/influxdata
	git clone $2
	cd $(ls)
	. goenv.sh && gdm restore && goGetVimGoDeps && goGetUtilDeps
	cd ../../../../../../
}

setupProject "c" "https://github.com/influxdata/plutonium"
setupProject "d" "https://github.com/influxdata/influxdb"
setupProject "m" "https://github.com/influxdata/plutonium-meta"
