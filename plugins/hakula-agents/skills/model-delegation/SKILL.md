---
name: model-delegation
description: >-
  Apply shared delegation briefs, tier boundaries, review, verification, and publication safeguards
  to every applicable delegate, and record correction evidence by actual model and snapshot. Use
  once per session before the first handoff to a non-flagship tier or another assistant, and again
  after a review or user steering corrects a delegate's work.
---

# Model Delegation

Start with the actual model's configured tier, since a client or model family can contain several tiers. Apply each safeguard below to every delegate when its conditions match the task, and scale review depth to the behavioral, structural, and publication risk.

Before handing off a task, check project memory for feedback applying to the selected role's model or snapshot and the task type. Honor any task-specific pause for the observed snapshot. When no relevant evidence is recorded, assign through the normal tier policy and standard review workflow.

## Tier boundaries and briefs

Keep design, convention judgment, goal-based sweeps, UI design, testing strategy, test writing, and final review with flagship-tier agents. Keep unattended memory consolidation with a flagship-tier agent across models and snapshots.

After a flagship-tier agent settles the design and requirements, give non-flagship delegates fully specified tasks with mechanically checkable edits or explicit source material for comparison. Exact edit lists, detailed findings with explicit limits, plain explanatory prose, and mechanically checked local work fit this tier when the brief supplies the necessary edge cases, limits, and comparison source.

Make each brief precise about:

- The objective, exact scope, exclusions, and stopping point.
- The files, interfaces, chosen approach, and exact edits when already decided.
- The edge cases, dependencies, acceptance criteria, and runnable checks.
- The required handoff evidence and questions that need coordinator resolution.

A delegate that disagrees with the brief or a review finding stops the affected work and escalates to the coordinator. Resolve the disagreement before changing requirements, design, scope, or acceptance criteria, using flagship-tier judgment where the tier boundaries apply.

## Independent review and evidence

Have a flagship-tier reviewer independent of the implementer review every delegated implementation and its tests, together with the commands and results behind behavioral claims. A focused review is sufficient for a minor mechanical change, while structural or behavior-heavy changes need correspondingly deeper checking.

For behavior-based acceptance, require each claimed result to name its command, outcome, full immutable commit SHA, and exact worktree path. Independently inspect or rerun the relevant checks at that revision. For a claim about a moving branch's current state, have the coordinator or flagship reviewer inspect the live head at acceptance, since an earlier SHA cannot establish the current state.

Rerun any probe cited to support a deviation from the brief or a review finding at the same revision, and resolve any discrepancy before accepting the deviation.

Check sibling consistency when structural edits follow established patterns. For documentation moves or edits involving dependencies or behavior, reconcile cross-references, dependency claims, and behavior descriptions with current code and affected documents before accepting absolute claims.

## Task-specific verification

Apply these checks when the task creates the corresponding risk:

- **UI and visual output**: Supply a measuring script when acceptance depends on measurements, exercise the final result in a browser, and inspect rendered screenshots of the relevant states before acceptance.
- **Behavior-heavy tests**: Use mutation testing when assertion strength is uncertain or the behavior is critical, including when line coverage is complete. Investigate surviving mutants in proportion to the behavior they exercise.
- **Resource-sensitive tests**: Report the measured environment and test conditions precisely, distinguishing configured resource limits from observed concurrency and recording parallelism settings that could change the result.
- **Dense-prose polishing**: Treat delegated polish of dense rule or reference prose as a draft. Before publication, have a flagship reviewer compare every changed hunk with the original and preserve prohibitions, attribution, claim boundaries, qualifiers, and evaluative vocabulary. Limit the assignment to narrative paragraphs when a full fidelity review would be disproportionate to the requested edit.

## Promotion and publication

For unattended promotion or publication that creates a public object, keep the work local until an independent reviewer verifies its content, target, shared-branch ownership, and public-facing author and committer identities, and a human explicitly approves creating that object. The approval names the object and its destination.

## Correction recording and assignment evidence

After a review or user steering corrects a delegate's work in the current session, save a project `feedback` memory recording:

- The actual model ID and snapshot from the delegate's transcript, since profile routing can assign another model and snapshots can change behavior.
- The task type and what failed or required steering.
- Whether the brief caused or contributed to the gap.

During memory maintenance, promote generalizable lessons into this common policy and keep model and snapshot observations in project memory. Change an assignment from model and snapshot evidence only when that evidence demonstrates a task-specific difference. A clear task-specific failure can justify pausing that task type for the same snapshot until a new snapshot or later evidence justifies restoring it. When the brief caused the gap, repair the brief and leave the assignment unchanged unless separate model evidence demonstrates a difference.
