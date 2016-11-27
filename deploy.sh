#!/bin/sh

# exit if any command fails
set -e

# Github repo to push changes to
DEPLOY_REPO=git@github.com:ch4lox/ch4lox.github.io.git
# If this is set, also try to purge cloudflare caches
CLOUDFLARE_ID=89f1dd69a9d7c7b97afeb1b51225dae2

if [ ! -f build/output/index.html ]; then
	echo 'build/output/index.html does not exist; run build.sh first!'
	exit 1;
fi

if [ ! -z "$DEPLOY_SSH_PRIVATE_KEY" ]; then
	eval "$(ssh-agent -s)"
	
	DEPLOY_SSH_PRIVATE_KEY_FILE=$(mktemp)
	chmod 600 $DEPLOY_SSH_PRIVATE_KEY_FILE
	echo $DEPLOY_SSH_PRIVATE_KEY|grep -Eo '\-----[^-]+-----'|head -n 1 > $DEPLOY_SSH_PRIVATE_KEY_FILE
	echo $DEPLOY_SSH_PRIVATE_KEY|grep -Eo '[^-]{64,}'|grep -Eo '.{,64}' >> $DEPLOY_SSH_PRIVATE_KEY_FILE
	echo $DEPLOY_SSH_PRIVATE_KEY|grep -Eo '\-----[^-]+-----'|tail -n 1 >> $DEPLOY_SSH_PRIVATE_KEY_FILE
	ssh-add $DEPLOY_SSH_PRIVATE_KEY_FILE
fi

TEMP_DIR=$(mktemp -d)

git clone ${DEPLOY_REPO} ${TEMP_DIR}

rsync -av --del --exclude='/.git' --exclude='/README.md' --exclude='CNAME' build/output/ ${TEMP_DIR}

cd ${TEMP_DIR}

git add --all .
git commit -m "Deployed using deploy.sh by ${USER} on $(hostname -s) at $(date)"
git push

if [ ! -z "$CLOUDFLARE_ID" ]; then
	echo "Purging Cloudflare caches..."

	if [ -z "$DEPLOY_CLOUDFLARE_EMAIL" ]; then
		echo "DEPLOY_CLOUDFLARE_EMAIL environment variable not set";
	fi
	if [ -z "$DEPLOY_CLOUDFLARE_KEY" ]; then
		echo "DEPLOY_CLOUDFLARE_KEY environment variable not set";
	fi
	if [ ! -z "$DEPLOY_CLOUDFLARE_KEY" ] && [ ! -z "$DEPLOY_CLOUDFLARE_EMAIL" ]; then
	curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ID}/purge_cache" -H "X-Auth-Email: ${DEPLOY_CLOUDFLARE_EMAIL}" -H "X-Auth-Key: ${DEPLOY_CLOUDFLARE_KEY}" -H "Content-Type: application/json" --data '{"purge_everything":true}'
	fi
fi

cd -
rm -rf ${TEMP_DIR}
