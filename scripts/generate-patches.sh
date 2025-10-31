#!/usr/bin/env bash
# Generate patch files for custom changes

set -e

PATCHES_DIR="$(dirname "$0")/../patches"
mkdir -p "$PATCHES_DIR"

echo "Generating patches from fork/master to master..."

# Generate patch for the symlink logic fix
git format-patch fork/master..master \
    --output-directory="$PATCHES_DIR" \
    --numbered \
    --no-stat

echo "Patches generated in $PATCHES_DIR/"
ls -la "$PATCHES_DIR"
