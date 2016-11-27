#!/bin/sh

# exit if any command fails
set -e

if [ -d build/cache ]; then
	rm -rf build/cache
fi
if [ -d build/output ]; then
	rm -rf build/output
fi

