---
name: release
description: >-
  Cut a repository release: draft and curate its CHANGELOG.md section with git-cliff in a release
  PR, tag the merged commit after approval, follow the release run, and republish corrected notes.
  Use when asked to release, tag, or ship a version, or to fix a published release's notes.
compatibility: Requires git-cliff and gh
---

# Release

Read the repository's release doc first, such as `RELEASING.md` or `docs/releasing.md`, since its version files, stability surface, and checks take precedence over these steps. Follow `git-workflow` for the release PR and the tag.

If the release tools are missing, Nix provides them:

```bash
nix shell nixpkgs#git-cliff nixpkgs#gh
```

Use the environment's existing GitHub authentication.

## Prepare the release PR

1. Branch from the default branch as `chore/release-vX.Y.Z`, and set each version file the release doc names to `X.Y.Z`, since a release workflow that compares the tag with the package version fails on a mismatch.

2. Draft the section with devkit's shared git-cliff config, or with plain `git cliff` when the repository has its own `cliff.toml`:

   ```bash
   git cliff \
     --config-url https://raw.githubusercontent.com/hakula139/devkit/v1.0.0-rc.3/cliff.toml \
     --unreleased \
     --tag vX.Y.Z \
     --prepend CHANGELOG.md
   ```

   devkit's config keeps `feat`, `fix`, `perf`, and any `!` title. git-cliff counts the commits it skips, and `-vv` lists them. A stable section covers its prereleases. For a prerelease such as `vX.Y.Z-rc.2`, add `--tag-pattern '^v[0-9]'` so the section starts at the previous tag of any kind.

3. Curate the draft for users, since PR titles are too short to explain a change:

   - State what users can now do, what no longer breaks, and what works differently, and lift migration notes from the PR descriptions. Omit implementation details.
   - Merge entries that describe one user-visible change, keeping every PR link, and move each entry to the group that matches its effect.
   - Drop entries with no user-visible effect, such as a CI-only change titled `fix`.
   - For a stable section, start from the curated sections of the prereleases it rolls up.
   - Fold any Unreleased section into the draft and delete it. Only the release PR edits `CHANGELOG.md`.

4. Run the repository's verification, then open the PR titled `chore(release): vX.Y.Z`. If another PR merges first, recreate the branch from the default branch and repeat these steps, since a rebased section misses the new commit.

## Tag the release

Pushing the tag starts the release workflow and is hard to undo, so get approval for it separately from the release PR's merge. Tag the release PR's squash commit by SHA, since a later PR may already sit on the default branch:

```bash
git fetch origin
git tag vX.Y.Z "$(
  gh pr view <number> \
    --json mergeCommit \
    --jq .mergeCommit.oid
)"
git push origin vX.Y.Z
```

Watch the release run with `gh run watch`. If the tagged commit has no passing push or dispatched CI run, rerun its failed CI jobs or dispatch a run with `gh workflow run ci.yml --ref vX.Y.Z`, then rerun the failed release jobs once that run passes. Check that the release notes match the section and that a prerelease tag published a prerelease.

## Republish release notes

The GitHub Release keeps its own copy of the notes. Once a PR that corrects a published section merges, use the repository's republish workflow if its release doc names one. Otherwise fetch `parse-changelog` and edit the release only if the parse succeeds, replacing `x86_64-unknown-linux-musl` with your system's target, such as `aarch64-apple-darwin`:

```bash
dir=$(mktemp -d)
gh release download \
  -R taiki-e/parse-changelog \
  -p 'parse-changelog-x86_64-unknown-linux-musl.tar.gz' \
  --dir "$dir"
tar -xzf "$dir"/parse-changelog-*.tar.gz -C "$dir"
"$dir/parse-changelog" CHANGELOG.md X.Y.Z >"$dir/notes.md" \
  && gh release edit vX.Y.Z --notes-file "$dir/notes.md"
```

## Report

Report the URLs of the release PR and the GitHub Release.
