# AGENTS.md: plugins

plugins holds Hakula's agent skills, grouped into plugins that coding agents install from one marketplace and that Nix consumers take from `lib.skills`.

## Layout

```text
.
├── .claude-plugin/    # The marketplace manifest
├── .cspell/           # Project spelling dictionary
├── .github/           # Renovate config and the CI workflow
├── nix/               # The skill check
├── plugins/           # One directory per plugin, with its manifest and skills
├── flake.nix          # `lib.skills`, checks, and the dev shell
└── README.md          # What the plugins hold and how to install them
```

## Rules for every change

- Run the pre-commit hooks on every commit. In each new checkout or worktree, run `nix develop -c true` once to install them. Never bypass the hooks with `--no-verify` or `PRE_COMMIT_ALLOW_NO_CONFIG`. When a hook, test, or CI job fails, fix its cause.
- Wrap code and comments at 100 columns, counting the indent, end section banners at column 100, and keep a single-line string literal whole at any length.
- Preserve the full self-use workflow when moving skills here. Each skill runs from its own directory with no build step and states the rules it needs inline. Nix may supply its tools and runtime dependencies. Keep maintained helpers with the skill, and retain model observations and operational constraints that affect its behavior. Defer host-specific configuration to the global instructions when the workflow needs that configuration.
- Name each skill uniquely across all plugins, since Nix consumers flatten them into one directory, and move a skill between plugins without renaming it.
- Bump a changed plugin's `version` in its `.claude-plugin/plugin.json` using semantic versioning so clients can detect updates. Skills share their plugin's release version. Keep the manifest as the only version source.
- Update the README's plugin table whenever a skill is added, moved, or renamed.
- Link only public material in skills, issues, pull requests, and their comments, and never reference local working notes, private paths, or private repositories.

## Verification

```bash
nix flake check --all-systems
claude plugin validate .
```

`claude` is unfree, so the validation runs locally and stays out of the flake.
