---
name: clean-gone
description: >-
  Remove finished local Git branches and stale linked worktrees while preserving useful local
  contents. Use when asked to clean up merged branches or worktrees, after a PR / MR merges or
  closes, or when git branch reports gone upstreams.
---

# Clean Gone Branches

Clean up the branches and worktrees covered by the task and its existing authorization. Keep unrelated ongoing work and coordinate with any owner before changing a worktree another session may use.

## Assess

Inspect the relevant Git refs, worktree contents, forge state, and owner or session information needed to decide whether the work is finished. Refresh remote information when that decision depends on it. A merged or closed request does not establish that later commits or uncommitted changes can be discarded. Account for squash merges when comparing completed work with the target branch.

## Preserve and remove

Retain worktrees with ongoing work, such as an open PR / MR. Remove a clean stale worktree in place without relocating it as an archive. Before removal, inspect tracked, untracked, and ignored contents for work worth keeping, including agent memory and plans. Move useful contents to a retained checkout or another durable location. Preserve same-name conflicts as complete separate files and report their destinations. Keep unpublished commits reachable. Ask when removing contents or commits would exceed the task's authorization.

Choose suitable Git or Workmux commands for the targets, using Workmux for worktrees it manages so its bookkeeping remains consistent. Keep the main checkout and leave the current worktree before removing it. Do not delete remote branches without explicit authorization.

## Verify and report

Read back the remaining worktrees, directories, and refs. After a denied or interrupted removal, inspect its actual outcome before retrying. Report what was removed, what was preserved and where, and what remains with its reason.
