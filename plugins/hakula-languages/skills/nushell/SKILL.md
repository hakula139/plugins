---
name: nushell
description: >-
  Write, review, and debug Nushell scripts and tests. Use when a task touches a `.nu` file or
  Nushell behaves unexpectedly.
---

# Nushell

## Scripts

- **Entry point**: `def main` with typed parameters.
- **Help**: limit the script header to its purpose and operating constraints, and document usage at each command and parameter so `--help` carries it.
- **Modules**: export only what another module or the module's own test calls, and keep other helpers private. Layer modules so imports point one way, with the entry importing domain modules and domain modules importing generic helpers.
- **Imports**: import a module by name when its commands share verbs with sibling modules, so calls read like `cache read` and `index read`. Otherwise list the imported commands, as in `use ./paths.nu [path-map path-match]`, so a reader sees where each name comes from. A test may `use ./<module>.nu *`.
- **Order**: order a module's sections as the pipeline first reaches them, and within a section put callees before callers. A test file follows its module's order.
- **Quoting**: quote string values, including paths and path segments, so they read as data. Use double quotes, switching to single quotes when the text holds a literal backslash or double quote, as a regex does. Leave names, flags, subcommands, and a builtin's own words bare, as in `decode utf-8`. Leave a glob meant to expand bare, and build a home path from `$nu.home-dir` because a quoted `~` stays literal. Keep the quotes any word needs to stay a literal string, as in `"0700"` and `"1min"`.
- **Path joins**: pass a literal relative path to `path join` as one `/`-separated string, as in `path join "libexec/gnubin"`, so it reads as the path it names, and give each segment that comes from a variable its own argument.
- **Script-relative paths**: locate files beside a script through a named constant at the top, as in `const SCRIPT_DIR = path self "."`, and join paths onto it. `path self` runs only at parse time and names the file it appears in, while `$env.FILE_PWD` and `$env.CURRENT_FILE` point at the running script even inside a module.
- **Multiline strings**: align the opening quote, content, and closing quote at the same column, then place `| str dedent` from `std-rfc/str` on the next line and any enclosing parenthesis on its own line.
- **Custom commands**: their switches stay on one line, as a builtin's do, since Nushell parses them itself.

## Traps

These traps assume the Nushell Book's [Thinking in Nu](https://www.nushell.sh/book/thinking_in_nu.html) and [Coming from Bash](https://www.nushell.sh/book/coming_from_bash.html). Reproduce a trap on the pinned Nushell before adding it.

### Parsing and data

- **`from json` accepts some plain text, so `try` cannot validate JSON.** `open` on an empty JSON, YAML, or NUON file returns null, while truncated JSON raises, so check the shape (`$j | describe | str starts-with "record"`) before reading a field.
- **`get -o` raises on rows that are not records.** It tolerates a missing column but fails on a list of strings or a scalar, so wrap it in `try` when the shape is unverified.
- **`get <n>` and `last` run every item of a stream and drop errors from the items they skip.** An `exit` or `error make` in a closure on a skipped item is discarded and the script continues, so only output the closure printed first, such as a `die` helper's message, still appears. Take a match with `first`, which stops pulling once it has one item and returns null on an empty stream.
- **Return annotations do not validate dynamic output.** A `-> record` function can return a list from an untyped helper, and `get -o` on an empty list returns `[]`, which `default` keeps.
- **A `mut` or a defaulted closure parameter takes the type of its initial value.** Each later value is checked against that type, at parse time when its type is known and at runtime otherwise, so `mut current = null` rejects a record, `mut n = 0` rejects a float, and `generate {|row, acc = null| ... }` raises `Can't convert to nothing` once it passes `acc` a value. Annotate the union, as in `mut current: oneof<record, nothing> = null`, because a linter misses the runtime case.
- **YAML error messages hide the parser's detail.** Read `$e.rendered` in the catch block, since `$e.msg` says only `Error while parsing as yaml`.
- **`math sum` errors on an empty list.** Use `| append 0 | math sum`.
- **`into datetime` reads a bare integer as nanoseconds.** A Unix timestamp in seconds needs `into datetime --format '%s'`.
- **`update` binds a named closure parameter to the row, not the cell.** Read the cell value from `$in`, as in `update body { $in | append $line }`.
- **`open --raw` yields a byte stream, which collects to `binary` on invalid UTF-8**, so a `: string` parameter or a `string ->` input raises a type error. To require UTF-8, pipe the stream itself into `into string` inside `try`, which raises `Non-UTF8 string` on invalid bytes and on a UTF-16 BOM. `into string` rejects every collected `binary`, valid or not.

### Strings and arguments

- **Bare words depend on context.** `where after != before` compares the `after` column with the string `"before"` (write `where after != $it.before`), and a comma splits a list item, so `[--sort=-pcpu,-pmem]` holds two items. Inside a list, an operator is a bare word too, so `["a" + $x]` holds three elements. Write `[("a" + $x)]` or `[$"a($x)"]`.
- **Outside parentheses or a list, a newline ends the command.** Arguments continue across lines only inside parentheses or a list, binary operators continue only inside parentheses, and a line starting with `|` continues the pipeline. A line starting with `and ($b)` calls a command named `and`, so wrap the whole expression in parentheses.
- **Dynamic regexes need single-quoted pieces.** Parentheses interpolate in both `$"..."` and `$'...'`, and double quotes consume backslashes, so concatenate them: `($label + ' (?<n>\d+)')`.
- **Forwarding arguments needs `def --wrapped`.** A plain `def` parses flags in `...args` itself. `--wrapped` also passes `--help` through as an argument, so a command whose operands may start with `-` keeps a plain `def` and its callers pass `--`.
- **`nu <script> <args>` re-parses the arguments as source text.** Nushell rebuilds the `main` call from the arguments, quoting one only when it holds whitespace or a special character such as `;` or starts with `$`, so an untyped `main` parameter receives `8` as an int. Three shapes stay code on the pinned Nushell ([nushell/nushell#19484](https://github.com/nushell/nushell/issues/19484)): the name part of a `--` argument before any `=`, even after a positional (`'--x;print INJECTED'` prints `INJECTED` when `main` accepts `--x` or the argument follows `--`); a bare redirection token (`'o>' out.txt` sends `main`'s output to `out.txt`, truncating it even when `main` only prints); and an argument starting with `...$` (`'...$env.PATH'` spreads `PATH` into the arguments). Never pass an untrusted string as a script argument. Pass it through stdin, an environment variable, or a file, or check it against an allowlist pattern first.
- **A flag on `def main` does not reach `def "main <sub>"`.** `script sub --flag` fails with an unknown flag, and `script --flag sub` passes `sub` to `main` as a positional, so declare a shared flag on each subcommand.
- **`url encode` escapes characters a URI keeps.** The default escapes every ASCII punctuation mark except `.`, `/`, and `:`, including the unreserved `-`, `_`, and `~`, and `--all` escapes those three as well. To match another encoder, pass only the characters it escapes through `url encode --all`.
- **`$nu.home-dir` ignores a `HOME` change inside the running Nushell.** It is fixed at startup, so code that runs after `$env.HOME = ...` or inside `with-env {HOME: ...}` in the same process reads `$env.HOME`. A child Nushell started with a new `HOME` sees it.
- **`str length` counts UTF-8 bytes by default.** `"中文字" | str length` returns 9 on the pinned Nushell. Pass `--chars` or `--grapheme-clusters` when a limit is written in characters.

### External commands

- **`cp` reports a refused read or write as `nu: <error>` and still succeeds.** Use `^cp` when that failure must raise an error.
- **A nonzero external exit ends the script with that code and prints nothing.** Tolerate it with `try`, or by using `| complete` and checking `.exit_code`. Piping into `ignore` discards the exit status along with the output, so after `^cmd | ignore` the script continues and can exit 0.
- **Reading stdin requires `^cat`.** `$in` is empty under a shebang that lacks `--stdin`, and reopening `/dev/stdin` fails with ENXIO on a socket. Text capture strips one trailing newline, so use `^cat | into binary` for byte-identical round trips.

## Testing

Test a script with `std/assert` when its output is easy to get subtly wrong. Drive it the way its caller does, and skip tests that only restate the code or require the external tools the script exists to call. Run an entry script through `^$nu.current-exe`, which names the running Nushell binary, so the script runs on the same Nushell as its test.

- **Layout**: a test sits beside the module or entry script it tests as `<module>.test.nu`.

- **Assertions**: compare the whole shape a test owns in one `assert equal`, so an unexpected field or row fails it.

- **Structured inputs**: write JSON and JSONL test inputs as Nushell records and lists, serialized with `to json` for JSON or `to json --raw` per line for JSONL.

- **Fixtures**: when several cases differ only in document-like or byte-sensitive inputs, store them as golden files under the project's fixture directory, with one directory per case.

  - A `case.nuon` file holds what the golden files cannot express. Write a line break as `\n`, except in a multi-line text string, which reads better as a multiline literal with continuation lines starting at column 0 because NUON preserves indentation as content. Format it like Nushell source, putting each list item on its own line.

  - Keep small structured inputs in the test file.

  - Copy each input into a `mktemp` directory before running the script so the script never writes to a fixture.

- **Timestamps**: fixtures use a fixed day in UTC, and a test that runs the script sets `TZ` for the child process, as in `with-env {TZ: "UTC"} { ^$nu.current-exe $script }`, so a local-time computation does not depend on the runner's zone.

### The nu-test runner

devkit's [`nu-test`](https://github.com/hakula139/devkit/blob/v3/docs/nu-test.md) runs each command named `test <behavior>` in a `.test.nu` file as one test:

- **Names**: a test name may hold only letters, digits, spaces, and `,.:-`, since the runner passes it to `nu --commands` as source text, where a quote, `;`, or `#` ends or breaks the command.
- **One process per test**: the tests run in parallel, each in its own `nu` process, so a test that changes its environment or exits cannot affect the others.
- **Load failures**: a file that fails to parse, or whose test names cannot be read, reports a `(load)` entry with its output and counts as a failure. A file that prints to stdout or exits while loading cannot report its test names, so it fails too.
- **Stubs**: a `<name>.stub.nu` file beside a test file is installed as an executable `<name>` in the directory `NU_TEST_STUBS` names, with a shebang line the runner writes in place of any the stub has. Call a stub by `$env.NU_TEST_STUBS | path join <name>` or by prepending that directory to `PATH`.
- **Shared helpers**: a `<name>.testlib.nu` file beside the test files holds builders that several of them `use`. devkit's `nuTests` copies it with the tests, while its packaging leaves `.test.nu`, `.stub.nu`, and `.testlib.nu` files out.
- **Scratch space**: `TMPDIR` points to a fresh empty directory for each test, which the runner removes after the run, even if the file fails to load.
- **Exit codes**: the runner prints one `PASS` or `FAIL` line per test and a `passed, failed` summary, then exits nonzero if any test fails or no tests run.

## Linting

`nu --ide-check` exits 0 even when it reports an error, printing diagnostics as JSON, so inspect the severities. Without a max-errors argument, it exits 1 before reading the file. Because it catches delimiter errors and local `def` arity mismatches but treats a mistyped command as an external call, run the script once for real.

Don't format with `nufmt`. It reindents to four spaces by default, and even with `indent: 2` in its config it joins a pipeline split one stage per line, or a call split one option per line, back onto one line.
