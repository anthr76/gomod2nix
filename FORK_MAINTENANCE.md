# gomod2nix Fork Maintenance Guide

This fork of `nix-community/gomod2nix` includes custom enhancements and maintenance automation.

## Custom Features

### 1. Sources Override (PR #123)
Adds ability to override the source fetcher by passing a `sources` parameter to `buildGoApplication`:

```nix
buildGoApplication {
  # ... other parameters ...
  sources = {
    "github.com/example/package_v1.0.0" = customSource;
  };
}
```

This allows you to provide pre-fetched sources or override specific package sources without modifying the fetcher logic.

### 2. Improved Symlink Logic
Properly handles directories vs files when creating symlinks in the vendor directory:
- Creates directories with `os.Mkdir` when needed
- Only creates symlinks for files
- Removes the need for `|| true` workaround for overlapped modules

## Maintenance Workflow

### Initial Setup (One-time)

```bash
# Ensure remotes are configured
git remote add fork https://github.com/nix-community/gomod2nix.git
git fetch fork

# Squash your history to clean commits (optional but recommended)
./scripts/squash-history.sh

# Regenerate patches
rm -rf patches/*.patch
./scripts/generate-patches.sh

# Commit the clean patches
git add patches/
git commit --amend --no-edit
```

### Regular Updates from Upstream

When `nix-community/gomod2nix` releases new changes:

```bash
# 1. Update from upstream and auto-apply your patches
./scripts/update-from-upstream.sh

# 2. Update dependencies
./scripts/update-deps.sh

# 3. Commit dependency updates
git add go.mod go.sum gomod2nix.toml flake.lock
git commit -m "chore(deps): update dependencies"

# 4. Test the build
nix build

# 5. Push to your fork
git push --force origin master
```

### Making New Changes

When adding new custom features:

```bash
# 1. Make your changes and commit
git add <files>
git commit -m "feat: your new feature"

# 2. Regenerate patches
./scripts/generate-patches.sh

# 3. Commit the updated patches
git add patches/
git commit -m "chore: update patches"

# 4. Push
git push origin master
```

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `update-from-upstream.sh` | Fetch upstream, reset branch, reapply patches |
| `update-deps.sh` | Update go.mod, gomod2nix.toml, flake.lock |
| `generate-patches.sh` | Create patch files from your commits |
| `squash-history.sh` | Clean up commit history (use sparingly) |

## Troubleshooting

### Patch Conflicts

If `update-from-upstream.sh` fails with patch conflicts:

```bash
# Option 1: Resolve conflicts manually
git am --continue
# after resolving conflicts

# Option 2: Skip the problematic patch
git am --skip

# Option 3: Abort and try manual rebase
git am --abort
git reset --hard backup-<timestamp>
git rebase -i fork/master
```

### Clean Slate

If things get messy and you want to start fresh:

```bash
# Save your custom changes as patches
./scripts/generate-patches.sh

# Reset to upstream
git reset --hard fork/master

# Reapply patches
for patch in patches/*.patch; do
  git am --3way "$patch" || break
done
```

## Why This Approach?

**Benefits:**
- ✅ Easy to update from upstream
- ✅ Clear separation of custom changes
- ✅ Automated patch application
- ✅ Can regenerate patches anytime
- ✅ Less painful rebasing

**Trade-offs:**
- ⚠️ Requires discipline to keep commits clean
- ⚠️ Patch files need to be regenerated after changes
- ⚠️ Force-pushes required (use `--force-with-lease`)

## Git Remotes

Your repository should have these remotes:

```bash
git remote -v
```

Expected output:
```
fork     https://github.com/nix-community/gomod2nix.git (fetch)
fork     https://github.com/nix-community/gomod2nix.git (push)
origin   git@github.com:anthr76/gomod2nix.git (fetch)
origin   git@github.com:anthr76/gomod2nix.git (push)
```

## Contributing Upstream

If you want to contribute a feature back to upstream:

```bash
# 1. Create a branch from upstream
git checkout -b feature-name fork/master

# 2. Cherry-pick your commit (not the patch commits)
git cherry-pick <your-feature-commit>

# 3. Create PR against nix-community/gomod2nix
```

## Questions?

See `scripts/README.md` for detailed script documentation.
