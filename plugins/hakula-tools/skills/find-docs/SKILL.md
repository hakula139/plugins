---
name: find-docs
description: >-
  Look up current documentation and examples with Context7. Use whenever a task depends on a
  library, framework, SDK, CLI tool, or cloud service's APIs, configuration, setup, migration, or
  version-specific behavior. Prefer this to web search for developer documentation.
compatibility: Requires the ctx7 CLI
---

# Find Docs

Verify library-specific details against current documentation, even for familiar APIs, with the `ctx7` command.

Keep a configured `ctx7` wrapper when available, since it may supply `CONTEXT7_API_KEY`. If authentication is needed, run `ctx7 login` or use the existing environment key.

If `ctx7` is missing, enter a Nix shell:

```bash
nix shell nixpkgs/nixos-unstable#ctx7
```

## Resolve the library

```bash
ctx7 library <name> "<focused documentation question>"
```

Resolve the name before querying docs unless the user supplies a Context7 ID such as `/org/project` or `/org/project/version`. Include the package's official name and the relevant API or behavior to distinguish similarly named projects, and select a version-specific ID when the task targets that version. If that version is unavailable, note which version the documentation covers and verify compatibility against the project's official docs.

## Query and verify

```bash
ctx7 docs <libraryId> "<focused documentation question>"
```

Keep each query focused on one topic. Follow the returned source links when snippets omit constraints or conflict, and link the authoritative documentation supporting the answer.

## Missing results and failures

Refine the query when results are irrelevant, and fall back to web search or fetch tools against official documentation or source when Context7 lacks coverage or fails. If no source can be reached, state the verification gap.
