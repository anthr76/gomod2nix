#!/usr/bin/env bash
# Update fork from upstream and reapply patches

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/../patches"

echo "=== Updating gomod2nix fork ==="
echo ""

# Fetch latest from upstream
echo "1. Fetching from upstream..."
git fetch fork

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Create backup branch
BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
echo "2. Creating backup branch: $BACKUP_BRANCH"
git branch "$BACKUP_BRANCH"

# Save maintenance files before reset
echo "3. Saving maintenance tooling..."
TEMP_DIR=$(mktemp -d)
if [ -d "scripts" ]; then
    cp -r scripts "$TEMP_DIR/"
fi
if [ -d "patches" ]; then
    cp -r patches "$TEMP_DIR/"
fi
if [ -f "FORK_MAINTENANCE.md" ]; then
    cp FORK_MAINTENANCE.md "$TEMP_DIR/"
fi

# Reset to upstream
echo "4. Resetting to fork/master..."
git reset --hard fork/master

# Restore maintenance files
echo "5. Restoring maintenance tooling..."
if [ -d "$TEMP_DIR/scripts" ]; then
    cp -r "$TEMP_DIR/scripts" .
fi
if [ -d "$TEMP_DIR/patches" ]; then
    cp -r "$TEMP_DIR/patches" .
fi
if [ -f "$TEMP_DIR/FORK_MAINTENANCE.md" ]; then
    cp "$TEMP_DIR/FORK_MAINTENANCE.md" .
fi
rm -rf "$TEMP_DIR"

# Apply patches if they exist
if [ -d "$PATCHES_DIR" ] && [ "$(ls -A $PATCHES_DIR/*.patch 2>/dev/null)" ]; then
    echo "6. Applying custom patches..."
    for patch in "$PATCHES_DIR"/*.patch; do
        echo "   Applying: $(basename $patch)"
        if ! git am --3way "$patch"; then
            echo ""
            echo "Patch failed to apply: $patch"
            echo "Please resolve conflicts manually and run:"
            echo "  git am --continue"
            echo "Or abort with:"
            echo "  git am --abort"
            echo "  git reset --hard $BACKUP_BRANCH"
            exit 1
        fi
    done
else
    echo "6. No patches found to apply"
fi

# Stage and commit the restored maintenance files
echo "7. Committing maintenance tooling..."
git add scripts/ patches/ FORK_MAINTENANCE.md 2>/dev/null || true
if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "chore: restore fork maintenance tooling"
fi

echo ""
echo "=== Update complete! ==="
echo "Your changes are in: master"
echo "Backup branch: $BACKUP_BRANCH"
echo ""
echo "Next steps:"
echo "  1. Update dependencies: ./scripts/update-deps.sh"
echo "  2. Test your changes"
echo "  3. Force push: git push --force-with-lease origin master"
