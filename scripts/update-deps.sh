#!/usr/bin/env bash
# Update go.mod, go.sum, gomod2nix.toml, and flake.lock

set -e

echo "=== Updating dependencies ==="
echo ""

# Update Go dependencies
if [ -f "go.mod" ]; then
    echo "1. Updating go.mod and go.sum..."
    go get -u ./...
    go mod tidy
    echo "   ✓ Go dependencies updated"
else
    echo "1. No go.mod found, skipping Go dependencies"
fi

# Update gomod2nix.toml
if command -v gomod2nix &> /dev/null; then
    echo "2. Updating gomod2nix.toml..."
    gomod2nix generate
    echo "   ✓ gomod2nix.toml updated"
else
    echo "2. gomod2nix not found in PATH"
    echo "   Run: nix develop -c gomod2nix generate"
fi

# Update flake.lock
if [ -f "flake.nix" ]; then
    echo "3. Updating flake.lock..."
    nix flake update
    echo "   ✓ flake.lock updated"
else
    echo "3. No flake.nix found, skipping flake update"
fi

echo ""
echo "=== Dependencies updated! ==="
echo ""
echo "Please review the changes and commit:"
echo "  git add go.mod go.sum gomod2nix.toml flake.lock"
echo "  git commit -m 'chore(deps): update dependencies'"
