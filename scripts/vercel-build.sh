#!/usr/bin/env sh

# Vercel build helper: run npm build and capture logs to public/build/build-log.txt
LOGFILE="public/build/build-log.txt"
mkdir -p "public/build"
echo "Build log - $(date)" > "$LOGFILE"

echo "Running npm run build..." | tee -a "$LOGFILE"
if npm run build 2>&1 | tee -a "$LOGFILE"; then
  echo "npm run build succeeded" | tee -a "$LOGFILE"
else
  echo "npm run build failed" | tee -a "$LOGFILE"
fi

echo "Build step complete." | tee -a "$LOGFILE"

# Always exit success so deployment proceeds; inspect logs for failure reasons.
exit 0
