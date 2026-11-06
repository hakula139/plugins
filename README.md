# plugins

[![CI](https://github.com/hakula139/plugins/actions/workflows/ci.yml/badge.svg)](https://github.com/hakula139/plugins/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Hakula's agent skills, packaged as plugins for Claude Code, Codex, and OMP.

## Plugins

The `hakula-plugins` marketplace holds four plugins. Each skill is a self-contained [Agent Skills][agent-skills] directory under `plugins/<plugin>/skills/`, and a skill's `compatibility` field names the tools it needs.

| Plugin             | Skills                                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------------------ |
| `hakula-workflow`  | `clean-gone`, `code-layout`, `git-workflow`, `release`, `review`                                       |
| `hakula-languages` | `nix`, `nushell`                                                                                       |
| `hakula-tools`     | `ast-grep`, `browser-debugging`, `cspell`, `disk-cleanup`, `find-docs`, `frontend-design`, `read-pdfs` |
| `hakula-agents`    | `acp-delegate`, `dream`, `harness-repair`, `model-delegation`                                          |

Several skills refer to each other by name, such as `review` to `git-workflow`, so install `hakula-workflow` beside any other plugin. The plugins track `main` and carry no versions.

## Install

### Claude Code

```bash
claude plugin marketplace add hakula139/plugins
claude plugin install hakula-workflow@hakula-plugins
```

Claude Code clones the marketplace over SSH when `ssh -T git@github.com` succeeds, and `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` makes it clone over HTTPS instead. `claude plugin marketplace update hakula-plugins` fetches later changes.

### Codex

```bash
codex plugin marketplace add hakula139/plugins
codex plugin add hakula-workflow@hakula-plugins
```

`codex plugin marketplace upgrade hakula-plugins` fetches later changes.

### OMP

```bash
omp plugin marketplace add hakula139/plugins
omp plugin install hakula-workflow@hakula-plugins
```

### Nix

The flake exports `lib.skills`, which maps each skill name to its directory with the tests and stubs left out, and `packages.<system>.clean-gone`, the command the `clean-gone` skill runs. A Home Manager module can link every skill into a client's skills directory:

```nix
plugins = {
  url = "github:hakula139/plugins";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
home.file = lib.mapAttrs' (
  name: source: lib.nameValuePair ".claude/skills/${name}" { inherit source; }
) inputs.plugins.lib.skills;

home.packages = [
  inputs.plugins.packages.${pkgs.stdenv.hostPlatform.system}.clean-gone
];
```

Outside Home Manager, `nix profile install github:hakula139/plugins#clean-gone` installs the command.

## Development

[`AGENTS.md`](AGENTS.md) is the contributor entry point for people and coding agents alike.

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz). Licensed under the [MIT License](LICENSE).

[agent-skills]: https://agentskills.io/specification
