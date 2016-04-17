#!/bin/sh

if [ -d "/tmp/go" ]; then
	rm -rf /tmp/go
fi
cp -r /home/dgnorton/bin/vim-go-with-binaries/go /tmp
cd /tmp/go/src/github.com/dgnorton/tmp
