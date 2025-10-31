#!/usr/bin/env bash
# Reset and create clean commit history

set -e

echo "=== Creating clean commit history ==="
echo ""

# Confirm with user
read -p "This will reset your branch history. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Create backup
BACKUP="backup-before-squash-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup branch: $BACKUP"
git branch "$BACKUP"

# Reset to upstream
echo "Resetting to fork/master..."
git reset --soft fork/master

# Create single commit with all changes
echo "Creating clean commits..."
git add builder/
git commit -m "feat: add custom enhancements

- Add sources parameter to override source fetcher (PR #123)
  Allows passing custom 'sources' to buildGoApplication to override
  the default source fetcher for specific packages

- Fix symlink logic for directories
  Properly handle directories vs files when creating symlinks in
  populateVendorPath, removing need for '|| true' workaround"

# Add scripts
git add scripts/ patches/
git commit -m "chore: add maintenance scripts and patches

- Add update-from-upstream.sh for easy rebasing
- Add update-deps.sh for dependency updates
- Add generate-patches.sh for patch generation
- Include patch files for easy reapplication"

echo ""
echo "=== Clean history created! ==="
echo ""
echo "Review with: git log fork/master..master"
echo "Backup branch: $BACKUP"
echo ""
echo "If satisfied, delete old patches and regenerate:"
echo "  rm -rf patches/*.patch"
echo "  ./scripts/generate-patches.sh"
