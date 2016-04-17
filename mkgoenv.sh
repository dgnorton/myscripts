#!/bin/bash

if [ -d "go" ]; then
	echo "go directory already exists"
fi

mkdir -p go/bin go/pkg go/src/github.com
