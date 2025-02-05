#!/usr/bin/env bash
set -e

ADDON_NAME="CommandSage"
VERSION="1.0"

rm -rf dist
mkdir -p dist build

mkdir -p build/$ADDON_NAME

# Include everything except .git, .github, dist, build, scripts, hidden files, markdown, and LICENSE
rsync -av --exclude='.git' --exclude='.github' --exclude='dist' --exclude='build' \
  --exclude='scripts' --exclude='.*' --exclude='*.md' --exclude='LICENSE' . build/$ADDON_NAME

cd build
zip -r "../dist/${ADDON_NAME}-${VERSION}.zip" "$ADDON_NAME"
cd ..
rm -rf build

echo "Built: dist/${ADDON_NAME}-${VERSION}.zip"
