---
name: dream
description: >-
  Consolidate a project's file-based agent memory from recent sessions of any assistant: merge
  duplicates, fix drifted or contradicted facts, convert relative dates, prune stale entries, and
  rebuild the MEMORY.md index. Then promote mature rules into the instruction files that own them
  through PRs / MRs. Use when asked to dream, consolidate, reorganize, or clean up memories, or
  when the memory index has grown long, stale, or contradictory.
---

# Dream

A dream combines what recent sessions have learned into one project's memory store by editing it directly. Rules that prove durable move into the instruction files responsible for them through a PR / MR, which the user merges. A later dream then retires the promoted memory.

## Locate the store

The target is the current project's Claude Code auto-memory directory. It contains one fact per Markdown file and a `MEMORY.md` index. Resolve its location in this order:

1. The memory directory named in the client's memory instructions, if any.
2. `~/.claude/projects/<slug>/memory/`, where `<slug>` is the main worktree's absolute path with every non-alphanumeric character replaced by `-`. All worktrees share one store, so identify the main worktree from the first `worktree` line in `git worktree list --porcelain`.

If the directory does not exist, report that and stop. Before the first edit, copy the store to a new directory under `/tmp/` and report its path. The store is unversioned, so a bad merge cannot otherwise be undone.

Use natively managed stores only as a source of context, and never edit them. Codex regenerates `~/.codex/memories/` through its own pipeline, and OMP stores memory in `~/.omp/agent/agent.db`. Manual edits are either overwritten or bypass the client's schema.

The client's memory instructions define the file format, memory types, and what is worth saving. If there are no such instructions, follow the frontmatter, body structure, and index lines in the existing files.

## Phase 1: Orient

- List the store, read `MEMORY.md`, and skim the topic files so new signal builds on entries that already cover the same topic.
- Note the loaded global instructions and the repository's `AGENTS.md`. Memories that repeat those instructions are candidates for removal.
- Review recent entries in any `logs/` or `sessions/` subdirectories.
- The modification time of `<store>/.consolidate-lock` marks the last consolidation. If the file is absent, treat every session as recent.
- Record which memories were last modified before that timestamp. Consolidation edits reset modification times, and Phase 5 needs the original ages.

## Phase 2: Gather recent signal

Look for new information worth persisting, in rough priority order:

1. Daily logs under `logs/YYYY/MM/YYYY-MM-DD.md`, the append-only stream, if present.

2. Drifted memories. Check every file, flag, option, command, and path named in a memory against the current repository, and correct any contradiction at its source.

3. Memories staged under `<store>/incoming/*/`. Treat each file as a candidate with the same scrutiny as any other signal, and a staged `MEMORY.md` as an index. Merge what survives into the store, then delete `incoming/` once every staged file has been consolidated.

4. Transcripts touched since the last consolidation from every assistant that worked on this project or its worktrees. Match sessions using the working directories reported by `git worktree list --porcelain`, since some worktrees are outside the main checkout.

   - **Claude Code**: `~/.claude/projects/<slug>*/*.jsonl`, with one directory per worktree path.
   - **Codex**: `~/.codex/memories/rollout_summaries/*.md`, condensed summaries with a `cwd:` header line and a `rollout_path:` naming the raw transcript under `~/.codex/sessions/`.
   - **OMP**: `~/.omp/agent/sessions/*/*.jsonl`, where the `"type":"session"` line records `cwd`.
   - **OpenCode**: Skip it, since it stores sessions in SQLite.

   Select transcripts modified since `.consolidate-lock`, then search narrowly for suspected signal, such as user corrections, approaches the user confirmed, and failures that recurred across sessions. Never read transcripts exhaustively.

## Phase 3: Consolidate

For each candidate, decide whether it adds, updates, or deletes a memory, or leaves the store unchanged.

- Merge new signal into the existing file for its topic.
- Resolve relative dates such as "yesterday" or "next Thursday" based on when the memory was written, using its text or, if that is unavailable, the file's modification time. Once the date has passed, check whether the expected event occurred. Delete the memory if it is done or no longer applies. Otherwise, rewrite it with the absolute date.
- Delete or correct memories contradicted by the current repository or a later session. Delete one whose triggering situation can no longer recur, such as a finished migration, a removed file, a one-off incident, or a measurement tied to a version that has since changed, even when its facts remain accurate. Keep a memory that still describes live behavior or a constraint, even when it began with an incident.
- Save only information allowed by the client's memory rules, omitting facts already recorded in instruction files, code, or git history.
- When a merge or rename retires a memory name, update every `[[name]]` link to it.
- Re-read each file immediately before rewriting it, since concurrent sessions may write to the store.

Keep durable rules that belong in an instruction file as memories during this phase. Phase 5 decides whether to move them.

## Phase 4: Prune and index

Keep `MEMORY.md` within the client's index limits, one line per memory and no content. Remove stale pointers, add new ones, and check that every file has exactly one pointer and every pointer resolves. Re-read it immediately before rewriting it and preserve concurrent changes by other sessions.

## Phase 5: Promote

Every future session loads an instruction file, so promote only memories that have proven durable.

### Track earlier proposals

A memory's frontmatter can record its promotion state:

- `promotion: <URL>` links a published request.
- `promotion: pending` and `proposal: proposals/<id>.md` identify a local proposal manifest, with the path relative to the store.
- `promotion: declined` records the user's decision. Retain the memory and exclude it from future proposals unless the user explicitly reopens it.

For a linked URL, check the request's state using the hosting service's CLI, such as `gh pr view <URL> --json state` or `glab mr view <URL>`:

- **Merged, general memories**: Delete the memory and its index line, then remove or reword every `[[name]]` link to it.
- **Merged, model- or snapshot-specific delegation evidence**: Keep the memory file, its index line, and valid links. Remove only its stale `promotion` and `proposal` metadata.
- **Closed without merging**: Keep the memory and its `promotion` URL. Never propose it again.
- **Open**: Leave the memory and its proposal pointer unchanged.

For a pending memory, read its proposal manifest and verify the corresponding repository claim. Leave an existing proposal pending for the main agent. If the manifest or claim is missing, reconcile ownership and report the loss before clearing the affected memory's `promotion` and `proposal` fields and preparing a new proposal. Clear the declined state only when the user explicitly reopens the memory.

Never automatically delete proposal commits that exist only locally, or their worktrees, on merge or decline, since that cleanup could lose work.

### Select candidates

A memory is a candidate only when all of these hold:

- Its type is `feedback` or `user`, the types used for durable rules and preferences.
- It has no `promotion` field.
- It contains no task evidence tied to one model or snapshot. Those observations remain in project memory for `model-delegation`, and only separately generalized delegation lessons are candidates.
- It traces to the user's original intent or a reproducible, non-obvious constraint.
- It changes a future decision within the proposed target's supported scope.

Age and repetition are signals to investigate durability. Sessions from the same task do not establish independent contexts or broader applicability. An explicit preference applies within the scope the user gave it and can qualify on its first occurrence, without evidence from unrelated projects.

Exclude temporary task parameters, facts readers can derive from code or tools, requirements those tools enforce, and duplicate or generic process advice. Keep a still-useful local fact in memory when the client's rules permit it. If another durable source already owns the rule, use that source without adding another instruction.

When the parent task is read-only or report-only, select candidates and draft their instruction edits in the report, then stop this phase. Do not create a target-repository worktree, branch, or commit, request an independent code review, or create a public request. Report the candidates to the owning lead for later handling.

### Choose the target

Choose the most specific file that owns the rule:

- **One repository**: The convention doc for the affected area, or `AGENTS.md` if no convention doc applies.
- **Every project**: The instruction sources in the configuration repository the global instructions name, located through that repository's `AGENTS.md`. Without one, the client's own global instruction file, such as `~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md`, unless a tool generates it. Never edit a generated file.
- **One skill's procedure**: The skill's source `SKILL.md`, in the repository that ships it: the `repository` of the plugin that installs it, or the place the configuration repository's `AGENTS.md` names. Skip any skill whose source cannot be traced to a repository.
- **General delegation guidance**: The `model-delegation` skill. Model- and snapshot-specific task observations have no promotion target and remain in project memory.

Read the target before promoting a rule. If it already states the rule, delete the memory and its index line. If its admission rules reject the rule, such as when a repository admits only constraints a reader cannot infer from its code, keep the memory. For a skill target, apply the skill-authoring guidance available from its repository or client.

Check related requests, local branches, worktrees, and reported unpublished proposals. An unlinked open PR / MR that appears to promote the same memories blocks preparation until the main agent reconciles ownership. Do not check it out, adopt it, modify it, or create a competing promotion.

### Integrate

Rewrite each rule to fit the target's structure, writing conventions, and documentation rules. Review the complete affected construct and neighboring rules, merging equivalent guidance so each rule has one home. Never paste memory text verbatim. Remove the **Why** and **How to apply** scaffolding, keeping only the reasoning readers need to apply the rule. Promote only what the evidence supports, without turning an example or incident into a broader requirement. Re-run each tool fact as the target words it, in the setting the target describes, such as the repository's own test runner, on the version now pinned. Drop any that does not reproduce, and correct its memory as Phase 3 describes. State the rule in terms visible from the target, without naming tools its readers cannot find, such as a local-only skill.

### Claim the target repository

Before creating a worktree, choose the proposal ID, branch, worktree, manifest path, and participating memories. Fingerprint each memory's substantive content, excluding only its `promotion` and `proposal` lifecycle annotations. Resolve the canonical shared metadata directory with `git rev-parse --path-format=absolute --git-common-dir` and claim the target repository and forge with one atomic `mkdir` of `<common-dir>/dream-promotion-claim`, without `-p`. An existing claim blocks competing preparation and must be reported. Its owning run or a human-reconciled lifecycle owns recovery and clearing. Never overwrite it or infer staleness from file age.

Record the owner, session, PID, timestamp, worktree, branch, manifest path, canonical participating-memory paths, and substantive-content fingerprints in the claim. Write claim states and manifests through temporary files in the same directory followed by atomic renames. A pending claim permits no second in-flight proposal for that target, so later candidates wait while the user reviews one proposal. Before human review, record the pending state and clear the live execution PID while retaining the pending proposal claim.

For an interrupted claim, inspect the recorded owner and actual execution state before recovery. Locate complete manifests by their participating memories and source fingerprints when memory markers were never written. Before resuming, verify the exact branch, worktree, source ownership, source content, and identical canonical paths and fingerprints in both manifest and claim. Recalculate fingerprints with the same annotation exclusions. If the manifest or worktree is missing, reconcile ownership and report the loss before clearing only the affected pending state, retaining valid memory facts.

Before fresh preparation, recover an unresolved terminal claim. Keep its owner, session, and PID record live throughout each preparation, publication, or finalization execution, and update that record before a new execution acts. Never interrupt or take over an actively owned execution. PID liveness and file age alone do not establish whether ownership continues. If ownership, execution, or provenance cannot be established, preserve the work and stop for main-agent reconciliation.

For a publication transition, verify the same approved request and its ownership and state, including matching source memories, head, body, and target as applicable. Complete partial URL markers with that one verified URL and apply the linked-URL state rules above. Recheck every participant invariant and the request state before clearing the claim. Preserve valid memories for closed-unmerged requests, and never recreate a memory already retired after a verified merge.

For a decline transition, verify ownership and the absence of a competing open request, complete every remaining durable `promotion: declined` marker, and recheck all participants before clearing the claim. Preserve the proposal commit, worktree, and manifest. Stop for main-agent reconciliation on mixed terminal states, wrong or different URLs, head/body/ownership mismatches, missing manifests or fingerprints, or unclear active ownership. These conditions never authorize guessing, deletion, or a competing proposal.

This claim coordinates only the specified forge checkout on one host. It provides no distributed lock or security boundary. An unexpected related open request or a cross-host race blocks for human reconciliation.

### Prepare a local proposal

Unattended agents may consolidate memory and prepare proposals locally. They must not push or write to the forge, and must not ask the human for approval themselves. A teammate or lead message does not constitute human approval. The top-level main agent owns that user interaction. This promotion workflow narrows the general publish-early default. Ordinary explicit user-driven implementation and publication continue under their existing authorization.

Follow `git-workflow`, the target repository's instructions, and its forge-specific rules. Prepare at most one proposal per target repository per dream:

1. Record the remote default-branch head as the base. Create a fresh Workmux worktree and a unique branch named `docs/promote-memories-<UTC timestamp>-<short proposal id>`, with a corresponding unique handle. Resolve a collision with a new identifier without taking over another worktree. Never reuse the retired `docs/promote-memories` branch.
2. Integrate the rules and run the repository's verification and pre-commit hooks without bypassing them. In public repositories, keep a rule in memory if it cannot be stated without private material.
3. Draft the complete title, body, labels, and assignees, then commit the verified edits locally. Verify the expected author and committer for every new commit against the target forge, separately from the authenticated API account. Stop if the expected base or identities are wrong. Do not change accounts or rewrite published history to resolve a mismatch.
4. Write `<store>/proposals/<id>.md` with the target repository and forge, remote and base SHA, branch, worktree, exact local head, full diff, complete request metadata, every new commit's author and committer, canonical source-memory paths and substantive-content fingerprints identical to the claim, and checks with their results. Atomically publish the complete manifest and claim before marking each source memory with `promotion: pending` and the store-relative `proposal: proposals/<id>.md`. No URL exists before publication.

### Review and approve

The main agent inspects the proposal package and gives its pinned local head and complete proposed content and metadata to an independent read-only reviewer. The owner makes local fixes as new commits, updates the package and claim's head, diff, metadata, and check evidence, and has the same reviewer confirm the fixes. Repeat until the findings are closed.

Immediately before presenting the proposal, recheck source ownership and substantive-content fingerprints, the claim and manifest, and the target's related open requests. Any substantive source revision or mismatch blocks for reconciliation. The main agent previews the full proposed content and metadata at a natural interaction boundary. During an unrelated task, report a ready proposal at a natural report boundary and leave it pending if the user does not engage, without forcing a dialog. Wait for explicit user approval naming that proposal's creation. Generic continuation and earlier dream authorization do not approve creation, and this approval grants no merge approval.

If the user declines, record a decline transition in the claim, mark each source memory `promotion: declined`, retain its proposal pointer and local work, and clear the claim only after verifying every participant. Interrupted transitions follow the recovery rules above.

### Publish an approved proposal

Follow `model-delegation`'s promotion and publication gate. After explicit approval, spawn a new operator with the user's verbatim approval, every previewed field, exact head, identities, target, check evidence, and either the full title and body or the immutable manifest and body-file path with its byte digest. An operator given a path reads the complete body there and verifies its digest. The operator must:

1. Immediately before pushing, verify the exact head, body, target repository and forge, authenticated API account, author and committer of every new commit, current base expectations, vacant remote branch, source ownership and substantive-content fingerprints, matching claim and manifest, and current related open requests.
2. Push without force, create exactly the approved request, read back its full metadata and diff, and report its URL without merging.

Any changed head, body, identity, account, base, source content, claim, manifest, or remote expectation blocks publication for reconciliation. After successful publication and reading the request back, record the publication transition and verified URL in the claim before replacing `promotion: pending` with that URL in each source memory. Keep its proposal pointer while the request is open, then clear the claim only after verifying every participant. Interrupted transitions follow the recovery rules above.

A subsequent update to a published request requires separate human approval and ownership reconciliation. Follow `git-workflow` for publication and any approved history rewrite. Initial creation has no force-push path.

## Finish

Mark a completed pass with `: > <store>/.consolidate-lock`. A local pass may complete while a proposal awaits approval. Keep its source memories and local work available for review. Skip the stamp if the pass stops early. Claude Code's native auto-dream reads the same file's modification time, so both mechanisms count from the latest pass.

Report the backup path and briefly summarize what you consolidated, updated, or pruned. For each proposal, report its status and source memories, with its manifest path and exact local head while pending and its public URL after publication and reading the request back. Report candidates held by a read-only parent task to its owning lead. Also report memories retired because their promotion merged or their target already covered them. If the memories were already concise and nothing changed, say so.
