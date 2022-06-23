#!/usr/bin/env bash
set -e
. /etc/profile || echo "WARNING: Failed to load environment variables"
set -x

echo "INFO: Starting package publishing process..."

rm -rfv ./bin
mkdir -p ./bin

cd ./build/web

zip -r ../../bin/html-web-app.zip ./*

sed -i 's/base href="\/"/base href=\".\/\"/' index.html

zip -r ../../bin/ipfs-web-app.zip ./*
