---
name: release
description: >-
  Prepare a repository release PR, draft and curate its notes, publish the approved tag, follow
  publishing, and correct published notes. Use when asked to release, tag, or ship a version,
  or to fix a published release's notes.
---

# Release

Read the repository's release contract, such as `RELEASING.md` or `docs/releasing.md`, for its version policy and files, notes source, checks, publishing targets, and recovery restrictions. Follow `git-workflow` for branches, PRs, and approved merges. Use existing GitHub authentication through `gh`. Changelog drafting also requires Nix and Nushell.

For shared release tooling, resolve a local released devkit source from the environment or the repository's locked input, using `nix flake archive --json` when needed. When neither supplies one, obtain the [released v1 source][devkit-source]. Read that source's `docs/releasing.md` for the script and publishing interfaces you use.

## Prepare the release PR

1. Create a release branch from the current default branch and update the version files, lockfiles, fixtures, and installation references required by the repository's contract.

2. Prepare the declared notes source. For a maintained `CHANGELOG.md`, run devkit's released draft script from the target repository's root:

   ```bash
   <devkit-source>/scripts/changelog.nu vX.Y.Z
   ```

   The script uses the repository's `cliff.toml` when present and otherwise uses devkit's shared template. It handles repository selection and prerelease ranges internally. The shared template drafts `feat`, `fix`, `perf`, and breaking changes, with stable release ranges covering their prereleases.

   When the repository's template supports highlights, pass a Markdown file:

   ```bash
   <devkit-source>/scripts/changelog.nu vX.Y.Z --highlights highlights.md
   ```

   For generated GitHub notes or annotated-tag notes, prepare that source as the repository specifies.

3. Curate the notes, run the required checks, and open the release PR titled `chore(release): vX.Y.Z`. If another change lands first, update the existing branch and regenerate the draft range while preserving curation.

## Curate the notes

Read PR descriptions when their titles leave the effect unclear.

- Preserve release history. Add the section in the release PR, fold Unreleased into it, and retain existing curated sections and compare links.
- For a stable release, start from its curated prerelease sections and add subsequent changes, preserving entries the draft's commit filter omits.
- Explain what users can do, what no longer breaks, what works differently, and required migration steps. Include only effects supported by the changes.
- Merge entries for one user-visible change, preserving every PR link. Fold fixes to a feature introduced in this release into that feature's entry.
- Preserve scope labels and the main change's scope. Split unrelated effects into separate entries.
- Group by effect, keep breaking changes under Breaking changes, omit changes with no user-visible effect, and order each group by user impact. Curate highlights by the same rules.
- Preserve the repository's format. Where compare references are required, compare stable releases with the previous stable tag and prereleases with the previous tag. For a first release, link to its release page. Keep reference definitions with their version section so extracted notes contain its metadata.

## Publish and verify

Prepare and verify the PR before requesting merge approval. Get approval to publish the tag separately, then tag the merged release commit identified by SHA, using the repository's tag type and approved annotated-tag notes.

Watch publishing through completion. Verify the declared notes source, prerelease status, and every expected artifact or registry package. Follow the repository's publishing interfaces and CI gates.

## Recover or correct notes

Let in-flight publishing finish and inspect each destination before retrying. Respect registry and tag immutability. Get explicit approval before deleting a release or moving a published tag, and prefer rerunning supported failed jobs at the same commit.

After a notes correction merges, use the repository's republish workflow when available. For changelog-based GitHub notes without one, use devkit's `scripts/github.nu release-notes OWNER/REPO <tag>` from the target repository root, with its documented dependencies available. Other notes sources follow the repository's correction procedure.

Report the release PR and published URLs, verification results, and incomplete targets.

[devkit-source]: https://github.com/hakula139/devkit/tree/v1
