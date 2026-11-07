---
name: harness-repair
description: >-
  Delegate a configuration-repository repair when an assistant encounters a concrete tool or
  environment malfunction, then publish the verified fix through a PR / MR while the main task
  continues.
---

# Harness Repair

Use this for a tool startup failure, a broken managed setting, or a reproducible environment regression that the configuration repository may own. Remote outages, missing account permissions, and ordinary project defects do not qualify.

## Dispatch

1. Locate the configuration repository the global instructions name. If they name none, or its checkout is missing, report the defect, its likely cause, and the manual fix, then continue the main task.

2. Start one background worker on a unique `fix/` branch based on the checkout's current commit, recording that commit and leaving the checkout's uncommitted changes in place. Verify the worker's checkout before its first edit.

   - Prefer the assistant's native background subagents, in a worktree you create.
   - Otherwise, run `workmux add <branch> --name <handle> --agent <assistant> --background --base <commit> -P <prompt-file>` from the checkout, plus `--parent-session` across projects. Choose the assistant explicitly and use a unique handle. Workmux creates the worktree, and `clean-gone` removes it once finished, as `git-workflow` describes, which also provides its Nix setup.
   - If neither route exists, say so and continue.

3. Brief it with the failing command and redacted error, the full path of the worktree it owns, and its scope: determine whether the configuration repository owns the cause, reproduce it where safe, fix it under the repository's `AGENTS.md`, verify the fix, and publish a PR / MR through `git-workflow` within any publication limit the task sets. It must not merge, run activation or service restarts, or start another repair.

Continue the main task meanwhile, and never dispatch a second worker for the same failure.

## Report

Inspect the diff, checks, and PR / MR before calling the repair done. Report the branch, commit, PR / MR URL or publication limit, checks, and anything unfinished, or the worker's handle and worktree while it runs. Promise a later notification only if the delegation mechanism supports one. Merging or activating the repair needs separate approval.
