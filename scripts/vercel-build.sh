#!/usr/bin/env sh
set -eu

npm run build

if [ ! -f public/build/manifest.json ]; then
  echo "ERROR: public/build/manifest.json was not generated" >&2
  ls -la public/build 2>/dev/null || echo "public/build does not exist" >&2
  exit 1
fi

echo "Vite manifest found:"
ls -la public/build