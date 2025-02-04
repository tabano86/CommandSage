#!/usr/bin/env bash
# scripts/build.sh
set -e

ADDON_NAME="CommandSage"
VERSION="1.0"

echo "Building $ADDON_NAME v$VERSION..."

rm -rf dist
mkdir -p dist build

# Copy entire folder except .git, scripts, dist, etc.
mkdir -p build/$ADDON_NAME
rsync -av \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='.gitignore' \
  --exclude='scripts' \
  --exclude='dist' \
  --exclude='build' \
  --exclude='*.md' \
  --exclude='LICENSE' \
  --exclude='.*' \
  . build/$ADDON_NAME

cd build
zip -r ../dist/${ADDON_NAME}-${VERSION}.zip $ADDON_NAME
cd ..
rm -rf build

echo "Done! See dist/${ADDON_NAME}-${VERSION}.zip"
