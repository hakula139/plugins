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

- **Judgment**: It applied a layout goal unevenly across sibling files, applied a reviewer's mistaken suggestion literally, and deleted accepted rationale comments while moving code.
- **Edge cases**: It follows exact edit lists and detailed review findings well, but it has mishandled edge cases even when the brief named them.
- **Verification**: A reviewer's mutation testing found plausible bugs its tests missed despite full line coverage. It also claimed a visual fix that failed browser verification and reported a Nushell probe result that a rerun disproved. Rerun any probe it cites to justify deviating from a review finding.
- **Documentation**: During a restructuring, it added a nonexistent module dependency and narrowed a relative attribution statement into an absolute one that excluded valid behavior. Check moved dependency and behavior claims against source, with flagship review of absolute claims.
- **Minified control flow**: It inverted a negated classifier denylist in an installed binary and produced an invalid routing recommendation from it. Keep this analysis and validator semantics on flagship models, and evaluate both branches of a negated condition independently.
- **Boundaries**: It overrode an explicit instruction over a concern that was already moot, and spent hours on probes outside the brief while others waited for its unpublished change.
- **Gateway images**: Its observed gateway route rejects screenshots returned inside tool results with HTTP 400 and ends the agent mid-task. Use a route that accepts tool-result images for image-reading work.

### Gemini 4 Argon (`gemini-4-argon`)

- **Prose polish**: With full-document context, polishing dense rule and reference prose repeatedly changed meaning through merged prohibitions, altered attribution, merged claims, added qualifiers, and swapped vocabulary. Treat its output as a draft and require hunk-by-hunk fidelity review against the original by a flagship reviewer before publishing. For dense reference text, consider polishing only the narrative paragraphs. It remains suitable for plain explanatory prose.
