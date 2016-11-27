#!/bin/sh

# exit if any command fails
set -e

. ./.helpers

exec ${JBAKE_HOME}/bin/jbake -b -s

