---
name: model-delegation
description: >-
  Match delegated work to models by their track record, and record what reviews and user steering
  reveal about a delegate. Use once per session before the first handoff to a non-flagship tier or
  another assistant such as Codex, and again after a review or the user corrects a delegate's work.
---

# Model Delegation

Delegate according to configured tiers, using the track record below to narrow model assignments. A model lacking a record for a given task type receives work like any other delegate, with the standard review workflow judging the result.

## Non-flagship delegates

Design and convention limitations observed in Codex (GPT) and DeepSeek inform this shared policy. Apply it according to the actual model's configured tier, since a client or model family can include several tiers.

Keep design, convention judgment, goal-based sweeps, and test writing with a flagship-tier agent. Once it settles the design, give non-flagship delegates fully specified tasks with mechanically checkable results. The brief names the files, approach, edge cases, checks, acceptance criteria, and stopping point.

Require delegates to raise disagreements for resolution before changing the requirements or scope. Have a flagship-tier agent independently review code changes and the verification behind behavioral claims. For UI work, supply a measuring script when the claim needs measurements, and verify the rendered result in a browser before accepting it.

## Recording

When a review or user steering corrects a delegate's work, save a `feedback` memory recording:

- The model ID with its snapshot, such as `DeepSeek-V4.1-Flash-1017`, read from the delegate's transcript, since a profile can route a role to another model and a new snapshot can alter the record.
- The task type and what required fixing or steering.
- Whether the brief left the gap, as gaps in the brief say nothing about the model.

One clear failure of the model's ability is enough to stop giving it that kind of task until its snapshot changes. The `dream` skill promotes these observations into the track record.

## Track record

### DeepSeek V4.1 Flash (`DeepSeek-V4.1-Flash-1017`)

- **Suitable tasks**: Exact edit lists and detailed review findings, with explicit edge cases and limits.
- **Do not delegate unattended**: Design or convention-heavy restructuring, documentation moves involving dependency or behavior claims, negated-condition analysis, minified or validator control flow, goal-based test design, and scope-sensitive cleanup.
- **Required review/verification**: Use flagship review for sibling consistency, dependency and absolute behavior claims, negated conditions, and validator semantics. Rerun any probe cited to deviate from a review finding. Verify UI changes in a browser, and use mutation testing to challenge behavior-heavy tests even when line coverage is complete.
- **Routing constraints**: State scope boundaries and stopping points in the brief. The observed gateway route rejects tool-result images with HTTP 400 and can end the agent mid-task. Use a route that accepts tool-result images for image-reading work.

### Gemini 4 Argon (`gemini-4-argon`)

- **Suitable tasks**: Plain explanatory prose.
- **Do not delegate unattended**: Publishing its polish of dense rule or reference prose, even when the full document supplies context.
- **Required review/verification**: Preserve prohibitions, attribution, claim boundaries, qualifiers, and evaluative vocabulary. Treat its output as a draft and require hunk-by-hunk fidelity review against the original by a flagship reviewer before publishing. For dense reference text, consider polishing only the narrative paragraphs.

### Kimi K3.1 Pro (`Kimi-K3.1-Pro`)

- **Suitable tasks**: Mechanically checked local work, including unattended memory consolidation.
- **Do not delegate unattended**: Promotion or publication with unresolved content, target, shared-branch ownership, public-facing identities, or human creation approval; and final-state verification on moving branches.
- **Required review/verification**: Independently check the live PR head before accepting current-state claims. Keep this verification with the coordinator or a flagship reviewer, or provide an immutable SHA and exact worktree path. Keep promotion local until an independent reviewer checks content, target, ownership, and author and committer identities, and a human explicitly approves public creation. Distinguish configured resource limits from observed concurrency, and report measured test conditions precisely.
