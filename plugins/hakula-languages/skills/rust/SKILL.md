---
name: rust
description: >-
  Write and review Rust code. Use when a task touches a `.rs` file or a Cargo manifest.
---

# Rust

## Lints and safety

- **Suppressions**: when a lint exception is justified, use `#[expect(lint, reason = "...")]` so an obsolete exception produces a warning. State why the code triggers the lint today.
- **Unsafe code**: follow the workspace's unsafe policy. Design unsafe abstractions around safety invariants, including state maintained by surrounding safe code. Document ownership, lifetime, and buffer constraints and any caller safety obligations.
- **Discarded values**: write `_ = expr` for an intentionally discarded value.

## Errors

- **Contracts**: keep errors structured when callers rely on their variants, methods, or stable public type. `thiserror::Error` supports structs as well as enums.
- **Context**: in application code already using `anyhow`, use `.context()` to identify the failed operation. Preserve the error boundaries callers already consume.
- **Panics**: reserve `expect()` for invariant failures, and state the invariant in its message.
- **Log events**: keep each `tracing` message constant and pass variable data as fields. Record an `anyhow` chain as `error = %format_args!("{e:#}")` and another `Display` value as `name = %value`.

## Visibility

Choose the narrowest visibility that serves supported callers. Use scoped visibility to express module boundaries, and preserve supported public library APIs even when no workspace crate calls them.

## Modules and imports

- **Module files**: put a module with children in `foo.rs` beside its `foo/` directory.
- **Import groups**: group `use` statements as std, external crates, workspace crates when present, then internal paths, with a blank line between groups.
- **Traits**: import a trait as `Trait as _` when only its methods are used, and by name when code names the trait, such as in a bound.

## Data

- **Optional fields**: omit `#[serde(default)]` on an ordinary `Option` field, since derived `Deserialize` reads a missing key as `None`. A field using `with` or `deserialize_with` may need an explicit default.

## Strings

- **Raw literals**: use a raw string when its content would otherwise need escaping, with the fewest `#` delimiters that work.
- **Multiline text**: when the project uses `indoc`, use `indoc!` for literals, `formatdoc!` for formatted text, and `writedoc!` with a writer to keep the content indented with its code.
- **Output lines**: in these macros, keep each output line on one source line, since reindenting a source continuation can change the de-indented text. A closing quote on its own line adds a final newline.
- **Captures**: capture format values inline by name, as in `{name}`. Bind an expression to a local named for its placeholder when it is not a plain identifier, so the template reads on its own.

## Dependencies

- **Workspace**: in a Cargo workspace, declare dependency versions once under the root manifest's `[workspace.dependencies]` and reference them from member crates with `dep.workspace = true`.
- **Platform**: declare a platform-specific dependency under the narrowest `[target.'cfg(...)'.dependencies]` table that covers its uses.
