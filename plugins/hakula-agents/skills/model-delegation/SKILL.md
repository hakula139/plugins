---
name: model-delegation
description: >-
  Match delegated work to models by their track record, and record what reviews and user steering
  reveal about a delegate. Use once per session before the first handoff to a non-flagship tier or
  another assistant such as Codex, and again after a review or the user corrects a delegate's work.
---

# Model Delegation

Delegate according to configured tiers, using the track record below to narrow model assignments. Apply the private track record the global instructions state, which takes precedence for the models it names. A model lacking a record for a given task type receives work like any other delegate, with the standard review workflow judging the result.

## Recording

When a review or user steering corrects a delegate's work, save a `feedback` memory recording:

- The model ID with its snapshot, such as `claude-sonnet-4-5-20250929`, read from the delegate's transcript, since a profile can route a role to another model and a new snapshot can alter the record.
- The task type and what required fixing or steering.
- Whether the brief left the gap, as gaps in the brief say nothing about the model.

One clear failure of the model's ability is enough to stop giving it that kind of task until its snapshot changes. The `dream` skill promotes these observations into the track record. An observation that names an internal snapshot or route goes to the private track record instead.

## Track record

- **Codex (GPT)**: Assign only fully specified tasks with mechanically checkable results, such as an exact edit list, because it does not reliably infer conventions or make design decisions. Keep design decisions, convention judgments, and test writing with Claude.
