---
name: release
description: >-
  Prepare and publish a repository version through its release PR and approved tag, follow the
  publishing workflow, or correct published notes using the shared devkit release guide.
compatibility: Requires gh. Changelog-based releases also require git-cliff.
---

# Release

Read the repository's release contract, such as `RELEASING.md` or `docs/releasing.md`, for its version policy and files, notes source, validation, publishing targets, and recovery restrictions. Follow `git-workflow` for branch and PR operations.

## Read the shared procedure

Read `docs/releasing.md` from the local devkit source identified by the global instructions. If no source is supplied, use the repository's locked devkit input, resolving its store path through `nix flake archive --json` when necessary. Read the guide before preparing or publishing a release. The installed local source works offline after its inputs have been fetched.

When no local source exists, read the [public devkit release guide](https://github.com/hakula139/devkit/blob/v1/docs/releasing.md). If it cannot be read, report that prerequisite and do not guess the publication procedure.

The guide owns the shared preparation, notes curation, release PR, exact-commit tagging, verification, and recovery procedure. Use the repository contract for its actual publishing interfaces. Bring an old instruction to push directly to the default branch or tag the current HEAD into line with the shared release PR procedure.

## Execute and verify

If `git-cliff` or `gh` is missing, enter a Nix shell:

```bash
nix shell nixpkgs#git-cliff nixpkgs#gh
```

Use existing GitHub authentication. For changelog drafting, prefer the repository's `cliff.toml`, then `cliff.toml` in the local devkit root, so drafting does not require a remote config request.

Prepare and verify the release PR before requesting its merge. Get approval to push the release tag separately from merge approval, and tag the merged release commit identified by SHA. Follow the repository's declared tag type and notes source. Do not assume that every repository maintains a changelog or uses devkit's Nix release workflow.

Watch publishing through completion and verify each target named by the contract. For corrected notes, use the repository's notes workflow when available, otherwise follow the guide's republish procedure for the declared notes source. Apply registry and tag immutability restrictions before attempting recovery.

Report the release PR and published release URLs with verification results and any incomplete targets.
