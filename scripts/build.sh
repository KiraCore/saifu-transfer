#!/usr/bin/env bash
set -e
. /etc/profile || echo "WARNING: Failed to load environment variables"
set -x


echo "INFO: Starting build & analyze process..."
uname -a

rm -rfv ./build

flutter --version

flutter packages pub get

flutter analyze --no-fatal-infos

flutter build web --release
