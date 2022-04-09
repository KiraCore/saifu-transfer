#!/usr/bin/env bash
set -e
. /etc/profile || echo "WARNING: Failed to load environment variables"
set -x

echo "INFO: Starting cleanup process..."
uname -a

flutter clean || echo "WARNING: Failed fvm clean" && sleep 3

./scripts/docker-clean.sh || echo "WARNING: Failed to clean docker" && sleep 3

rm -rfv ./build ./bin ./.dart_tool ./.packages ./.flutter-*
