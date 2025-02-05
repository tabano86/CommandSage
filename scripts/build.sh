#!/bin/bash
set -euo pipefail
if [ -f dist/CommandSage.zip ]; then
  rm dist/CommandSage.zip
fi
mkdir -p dist
zip -r dist/CommandSage.zip . \
  -x "*.git*" \
  -x "dist/*" \
  -x "tests/*" \
  -x "scripts/*" \
  -x ".*"
echo "Build complete."
