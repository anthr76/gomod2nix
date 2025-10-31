# Custom Patches

This directory contains patches for features from upstream PRs that haven't been merged yet.

## Applied Patches

### 0001-feat-add-sources-parameter-to-override-source-fetcher.patch
**Source:** [PR #123](https://github.com/nix-community/gomod2nix/pull/123)
**Author:** Julien Salleyron
**Status:** Open (since Sep 1, 2023)

Adds ability to override the source fetcher by passing a `sources` parameter to `buildGoApplication`. This allows providing custom sources for specific packages without modifying the fetcher logic.

**Usage:**

```nix
buildGoApplication {
  # ... other parameters ...
  sources = {
    "github.com/example/package_v1.0.0" = customSource;
  };
}
```

### 0002-fix-properly-handle-directories-in-symlink-logic.patch
**Source:** [PR #158](https://github.com/nix-community/gomod2nix/pull/158)
**Status:** Improves symlink handling

Properly handles directories vs files when creating symlinks in the vendor directory:
- Creates directories with `os.Mkdir` when needed
- Only creates symlinks for files
- Recursively handles nested directory structures

This removes the need for `|| true` workarounds and provides more robust vendoring behavior.## Updating Patches

To update these patches to newer versions from upstream:

```bash
# Download latest version of a patch
curl -sL https://patch-diff.githubusercontent.com/raw/nix-community/gomod2nix/pull/123.patch \
  -o patches/0001-add-sources-parameter.patch

# Test if patches still apply
git apply --check patches/*.patch
```

## Automatic Application

These patches are automatically applied when running:
```bash
./scripts/update-from-upstream.sh
```

The script will:
1. Reset to upstream `fork/master`
2. Apply each patch in numerical order
3. Create a commit for the maintenance tooling
