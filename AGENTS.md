# AGENTS.md: plugins

plugins holds Hakula's agent skills, grouped into plugins that coding agents install from one marketplace.

## Layout

```text
.
├── .cspell/     # Project spelling dictionary
├── .github/     # Renovate config and the CI workflow
├── flake.nix    # Checks and the dev shell
└── README.md    # What the plugins hold and how to install them
```

## Rules for every change

- Run the pre-commit hooks on every commit. In each new checkout or worktree, run `nix develop -c true` once to install them. Never bypass the hooks with `--no-verify` or `PRE_COMMIT_ALLOW_NO_CONFIG`. When a hook, test, or CI job fails, fix its cause.
- Wrap code and comments at 100 columns, counting the indent, end section banners at column 100, and keep a single-line string literal whole at any length.
- Link only public material in skills, issues, pull requests, and their comments, and never reference local working notes, private paths, or private repositories.

## Verification

```bash
nix flake check --all-systems
```
