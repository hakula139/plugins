---
name: rust
description: >-
  Write and review Rust code. Use when a task touches a `.rs` file or a Cargo manifest.
---

# Rust

## Lints

- **Suppressions**: use `#[expect(lint, reason = "...")]`, with a reason that says why the code triggers the lint today (`allow_attributes`, `allow_attributes_without_reason`).
- **Complexity and size**: when a complexity or size lint, such as `too_many_lines` or `too_many_arguments`, fires, extract a helper or bundle the parameters that belong together into a struct. Suppress it only for an irreducibly cohesive function, and explain why in the reason.
- **Unsafe code**: deny `unsafe_code` across the workspace, or forbid it when no platform call needs an exception, since `forbid` also rejects an inner `#[expect]`. Wrap each call that has no safe API in one function that carries a function-scoped `#[expect(unsafe_code, reason = "...")]`, keep raw handles and pointers inside it, document their ownership and buffer invariants, and expose a safe operation.
- **Discarded values**: write `_ = expr`, which `let_underscore_untyped` accepts while it flags an untyped `let _ = expr`.

## Errors

- **Error types**: in application code, return `anyhow::Result` with `.context()` messages that say what failed, and derive `thiserror::Error` only for an error whose variants callers match on.
- **Panics**: call `unwrap()` only in tests (`unwrap_used` with `allow-unwrap-in-tests` in `clippy.toml`). Reserve `expect()` for calls that cannot fail, and state the invariant in its message, as in `.expect("the bundled theme must parse")`.

### Error messages

With `{:#}`, `anyhow` renders a chain as one sentence, `outer: inner: innermost`, so write each message as a lowercase fragment of it:

- **Headline**: say what failed and name the variable, key, file, or value involved. A failed operation reads `failed to <verb> ...`, as in `failed to read the current working directory`, and rejected input names the problem first, as in `invalid PORT "80a": expected a whole number from 1 to 65535`. Quote user-supplied text with `{:?}`.
- **Display site**: where a surface shows a chain on its own, capitalize the headline it adds there, as in `Import failed: {e:#}`, so the messages inside stay lowercase. `main` reports a startup error after `Error:`, so its outermost message stays lowercase too.
- **Recovery step**: put a recovery step after the innermost cause, which renders last, as in `invalid PATH_LIST "a,,b": empty entry between commas. Remove the stray comma.` When such an error wraps a cause, format the cause into its headline so the step stays last.

### Log events

Keep each `tracing` message a constant phrase and pass variable data as fields, so filters and readers can match one event across occurrences. Record an `anyhow` chain as `error = %format_args!("{e:#}")` and another `Display` value as `name = %value`, as in `warn!(?delay, attempt, error = %format_args!("{e:#}"), "retrying the request")`.

## Visibility

Use the narrowest visibility that works, trying private, `pub(super)`, `pub(crate)`, and `pub` in that order.

- **Crate root**: in a direct child of the crate root, where `pub(super)` already reaches the whole crate, write `pub(crate)`.
- **Public items**: in a crate that is not published, make an item `pub` only when another workspace crate uses it or a `pub` signature names it, and make every module on its path `pub` too, so `pub(crate)` marks an item that serves its own crate alone.
- **Dead code**: rustc never reports an unused `pub` item reachable from the crate root, even in a binary. A binary crate therefore has no `pub` items, and in a crate that is not published, a change that removes an item's last use from another crate also narrows or deletes it.
- **Scoped forms**: skip `pub(in path)`. When modules outside an item's parent use it, move it into their nearest common module, or into a child of that module with `pub(super)`.

## Modules

- **Module files**: put a module with children in `foo.rs` beside its `foo/` directory (`mod_module_files`).
- **Shared items**: put a type or trait that several modules share in the module that owns its contract.
- **Platform variants**: keep `#[cfg(unix)]`, `#[cfg(windows)]`, and `#[cfg(target_os = "macos")]` variants together in the module they belong to, without per-platform files.
- **Re-exports**: avoid `pub use` re-exports that hide where an item is defined. A module that re-exports some items re-exports every related item, so callers reach them through consistent paths.

## Imports

- **Groups**: order `use` groups as std, external crates, workspace crates, then internal `self::`, `super::`, and `crate::` paths, with a blank line between groups. Stable rustfmt sorts each group, putting `self` before `super` before `crate`, but never moves an import between groups, so keep the grouping by hand.
- **Paths**: reach a module's children through `self::` and its parent and siblings through `super::`, in re-exports too. Use `crate::` for more distant modules and in test modules, which already glob-import their parent.
- **Traits**: import a trait as `Trait as _` when only its methods are used, as with `std::fmt::Write as _`, and by name only where code names the trait, such as in a bound (`unused_trait_names`).

## Types

- **Derives**: list derives in the order `Debug`, `Clone`, `Copy`, `Default`, `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`, then `Serialize` and `Deserialize`, then other crates' derives such as `thiserror::Error`, and give parallel types the same set. rustfmt merges adjacent `#[derive]` attributes but keeps their order.
- **Trait metadata**: put per-implementation metadata, such as a display name or an input summary, in a trait method, so adding an implementation edits only its own file.
- **Optional fields**: omit `#[serde(default)]` on an `Option` field, since derived `Deserialize` reads a missing key as `None` unless the field sets `with` or `deserialize_with`.

## Layout

- **Module order**: open a module with its `//!` doc, then its `mod` declarations, its re-exports at any visibility as a group of their own, and its `use` groups.
- **Helper order**: within each section, put helper functions after their callers, so the file reads from top to bottom.
- **Section banners**: separate distinct groups of items with `// ── Section Name ──` banners drawn with U+2500 (`─`).

## Strings

### Literals

- **Plain**: write text that renders as one line as a plain literal while it fits within the line limit, rustfmt's `max_width` (100 by default).
- **Continued**: past the limit, continue a prose literal with `\`. rustfmt leaves a statement unformatted when one of its literals runs past `max_width`, so this rule overrides `code-layout`'s rule to keep a one-line literal whole. Fill each line like a comment and start each continued line one column past the opening quote. The continuation drops the next line's leading whitespace, so keep the space between the joined words before the `\`. rustfmt never realigns continuation lines when it moves a literal, so realign them by hand.
- **Raw**: use a raw string only when the text holds characters that would otherwise need escaping, with the fewest `#` delimiters (`needless_raw_string_hashes`), and only when it fits on one line or forms a multiline `indoc!` or `formatdoc!` body. A raw string cannot continue with `\`, so prose past the limit becomes an escaped continued literal, while a one-line machine-format fixture, such as compact JSON or a regex, stays raw at any length.
- **Column-checked rows**: keep a rendered row whose test compares output line by line and checks column alignment, such as a terminal line, on one source line at any length.
- **Escapes**: `\n` escapes suit a single trailing newline, a tiny non-prose fixture, and, when clear, a one- or two-line fixture without a paragraph break. Keep text whose meaning depends on trailing spaces or whitespace-only lines in an escaped literal, since editors and whitespace hooks strip them.
- **Owned strings**: convert a literal with `.to_owned()` and keep the layout rustfmt gives the chain. Don't wrap the literal in `String::from` or bind it to a local only to change that layout.

### Multiline text

Use `indoc!` for literals, `formatdoc!` for formatted text, and `writedoc!` with a writer whenever prose or a structured document, such as a prompt, a message, Markdown, a diff, or a file fixture, spans a paragraph break or three or more lines. This applies to tests as well as production code. Inline the call where its text is used once, and name a constant only when the text is shared or very large. A large static prompt goes in its own file, as `code-layout` describes, while a prompt that interpolates values stays an inline `formatdoc!` template.

Write a multiline `indoc!` or `formatdoc!` call with braces, since rustfmt lays out a parenthesized one like a function call. Close it on its own line at the indentation of the line that opens it, with `"}` when the text ends in a newline. Otherwise the closing `"` stays on the last content line and `}` starts the closing line, since a `"` on its own line adds a final newline:

```rust
let usage = indoc! {"
    Usage: app <command>

    Run `app help` to list the commands.
"};

let error = formatdoc! {"
    Model `{name}` is ambiguous:

    {models}"
};
```

- **Captures**: capture each value inline by name, as in `{name}`, the style `uninlined_format_args` enforces for `format!`. Bind a value that is not a plain identifier, such as `body.len() + 1`, to a local named for its placeholder before the call, so the template reads on its own.
- **Source lines**: keep each output line on one source line, even past the line limit. When rustfmt moves the call, it can re-indent a body line that ends in a `\` continuation apart from its neighbors, which changes the text `indoc!` produces.
- **`writedoc!`**: rustfmt lays out a multiline `writedoc!(writer, "...")` like a function call, so the writer, the literal, and the closing `)` each start their own line.
- **CRLF**: for protocol text such as an HTTP request, end each line with `\r` and let the source line break supply the `\n`.
- **Interpolated lists**: build a list or section that a template interpolates without a trailing newline, joining its items with `join`, so the template owns the line breaks around it.

## Dependencies

- **Workspace**: declare each dependency, with its version requirement, once in the root `Cargo.toml` under `[workspace.dependencies]`, and reference it from member crates with `dep.workspace = true`.
- **Platform**: reference a platform-specific dependency from the member crate under the narrowest `[target.'cfg(...)'.dependencies]` table that covers every use.
- **Choice**: prefer crates with few transitive dependencies.

## Warnings

A workspace that sets `build.warnings = "deny"` in `.cargo/config.toml` fails builds, tests, Clippy, and `cargo doc` on any lint warning, including those rustdoc reports. Cargo fails each crate that warns and then starts no further crates, so pass `--keep-going` to build and report every crate, or set `CARGO_BUILD_WARNINGS=warn`, which also works for `cargo test`, where `--keep-going` is unavailable. Cargo respects the setting from 1.97, so an older toolchain, such as one that checks the minimum supported Rust version, lets warnings pass.
