---
name: release
description: >-
  Prepare a repository release PR, draft and curate its notes, publish the approved tag, and
  follow publishing. Use when asked to release, tag, or ship a version.
---

# Release

Read the repository's release contract, such as `RELEASING.md` or `docs/releasing.md`, for its version policy and files, notes source, checks, publishing targets, authentication, tooling, and recovery restrictions. Follow the declared tooling's documentation and use the target's existing authentication. Follow `git-workflow` for branches, PRs, and approved merges.

## Prepare the release PR

1. Create a release branch from the current default branch and update the version files, lockfiles, fixtures, and installation references required by the repository's contract.

2. Prepare the declared notes source using the repository's specified draft tooling and inputs, including highlights when supported.

3. Curate the notes, run the required checks, and open the release PR using the repository's release contract and the conventions established through `git-workflow`. If another change lands first, update the existing branch and regenerate the draft range while preserving curation.

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

## Recover

Let in-flight publishing finish and inspect each destination before retrying. Respect registry and tag immutability. Get explicit approval before deleting a release or moving a published tag, and prefer rerunning supported failed jobs at the same commit.

Report the release PR and published URLs, verification results, and incomplete targets.
