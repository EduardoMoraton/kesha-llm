#!/bin/sh
# Dev loop: copy sources to the Cardputer, build the .deb there and install it. Usage: ./deploy.sh [user@host]
set -eu
HOST=${1:-pi@192.168.1.155}
cd "$(dirname "$0")"
rsync -a --exclude build --exclude dist ./ "$HOST:kesha-llm/src/"
ssh -t "$HOST" 'cd ~/kesha-llm/src && ./build-deb.sh && sudo dpkg -i dist/kesha-llm_*_arm64.deb'
