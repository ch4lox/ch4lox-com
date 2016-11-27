#!/bin/sh

# exit if any command fails
set -e

if [ ! -f build/output/index.html ]; then
	echo 'build/output/index.html does not exist; run build.sh first!'
	exit 1;
fi

DEPLOY_REPO=git@github.com:ch4lox/ch4lox.github.io.git
TEMP_DIR=$(mktemp -d)

if [ ! -z "$DEPLOY_SSH_PRIVATE_KEY" ]; then
	eval "$(ssh-agent -s)"
	
	DEPLOY_SSH_PRIVATE_KEY_FILE=$(mktemp)
	chmod 600 $DEPLOY_SSH_PRIVATE_KEY_FILE
	echo "$DEPLOY_SSH_PRIVATE_KEY" > $DEPLOY_SSH_PRIVATE_KEY_FILE
	ssh-add $DEPLOY_SSH_PRIVATE_KEY_FILE
fi

git clone ${DEPLOY_REPO} ${TEMP_DIR}

rsync -av --del --exclude='/.git' --exclude='/README.md' --exclude='CNAME' build/output/ ${TEMP_DIR}

cd ${TEMP_DIR}

git add .
git commit -m "Deployed using deploy.sh by ${USER} on $(hostname -s) at $(date)"
git push

cd -
rm -rf ${TEMP_DIR}
