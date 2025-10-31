# Fork Maintenance Scripts

This directory contains scripts to help maintain this fork of gomod2nix.

## Scripts

### `update-from-upstream.sh`
Updates the fork with the latest changes from upstream and reapplies custom patches.

```bash
./scripts/update-from-upstream.sh
```

**What it does:**
1. Fetches latest changes from `fork` remote (nix-community/gomod2nix)
2. Creates a backup branch
3. Resets your branch to upstream
4. Applies custom patches from `patches/` directory
5. Provides instructions for next steps

### `update-deps.sh`
Updates all dependency files (go.mod, go.sum, gomod2nix.toml, flake.lock).

```bash
./scripts/update-deps.sh
```

**What it does:**
1. Updates Go dependencies (`go get -u && go mod tidy`)
2. Regenerates `gomod2nix.toml`
3. Updates `flake.lock`

### `generate-patches.sh`
Generates patch files from your custom commits.

```bash
./scripts/generate-patches.sh
```

**What it does:**
1. Creates `.patch` files for all commits on top of `fork/master`
2. Stores them in the `patches/` directory
3. These patches can be reapplied after updating from upstream

## Workflow

### Initial Setup

1. **Create clean commits** for your custom changes:
   ```bash
   # Squash your commits into meaningful ones
   git rebase -i fork/master
   ```

2. **Generate patches**:
   ```bash
   ./scripts/generate-patches.sh
   ```

3. **Commit the patches**:
   ```bash
   git add patches/
   git commit -m "chore: add maintenance patches"
   ```

### Regular Updates

When upstream releases new changes:

```bash
# 1. Update from upstream and reapply patches
./scripts/update-from-upstream.sh

# 2. Update dependencies
./scripts/update-deps.sh

# 3. Review and commit dependency updates
git add go.mod go.sum gomod2nix.toml flake.lock
git commit -m "chore(deps): update dependencies"

# 4. Test your changes
nix build

# 5. Push to your fork
git push --force-with-lease origin master
```

## Custom Patches

This fork includes the following custom patches:

1. **PR #123 - Add sources to override sources fetcher**
   - Allows passing custom `sources` parameter to `buildGoApplication`
   - Enables overriding the default source fetcher for specific packages

2. **Symlink logic improvements**
   - Properly handles directories vs files when creating symlinks
   - Removes the `|| true` workaround for overlapped modules

## Remotes

Expected git remotes:
- `origin`: Your fork (anthr76/gomod2nix)
- `fork` or `upstream`: Upstream repository (nix-community/gomod2nix)

Set them up if needed:
```bash
git remote add fork https://github.com/nix-community/gomod2nix.git
git fetch fork
```
