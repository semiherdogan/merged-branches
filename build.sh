#!/bin/bash

# Build script for merged-branches

VERSION=${1:-"1.0.0"}
PLATFORM=${2:-"$(uname -s | tr '[:upper:]' '[:lower:]')"}
OUTPUT="merged-branches-$PLATFORM"

echo "Building version $VERSION for $PLATFORM..."

go build \
  -ldflags "-X 'github.com/semiherdogan/merged-branches/internal/config.Version=$VERSION' -X 'github.com/semiherdogan/merged-branches/internal/config.Platform=$PLATFORM'" \
  -o "$OUTPUT" \
  ./cmd/merged-branches

if [ $? -eq 0 ]; then
  chmod +x "$OUTPUT"
  echo "Build successful: $OUTPUT"
  ./"$OUTPUT" --version
else
  echo "Build failed"
  exit 1
fi
