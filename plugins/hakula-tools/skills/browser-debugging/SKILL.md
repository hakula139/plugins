---
name: browser-debugging
description: >-
  Investigate web UI failures, visual regressions, and browser performance. Use for browser testing,
  Playwright scripts, screenshots, console or network inspection, and cross-browser reproduction.
compatibility: Requires Python Playwright for scripted runs
---

# Browser Debugging

## Choose the tool

Reuse available browser tools before installing Playwright or downloading browser binaries:

- Use the assistant's native browser controls, when available, to navigate and inspect pages interactively.
- Use Chrome DevTools MCP to capture performance traces and diagnose console errors and network issues.
- Use Python Playwright to run reproducible scripts or compare Chromium, Firefox, and WebKit.

## Run standalone automation

If `uv` is missing, enter a Nix shell:

```bash
nix shell nixpkgs#uv
```

Run Python Playwright scripts in the Playwright environment that the global instructions or the project name, which pairs a Playwright version with its browser binaries. Without one, use a Python environment whose `playwright install` fetched the browsers for its own `playwright` package. Use headless mode by default, and choose Firefox or WebKit when the issue involves another engine:

```bash
uv run --with playwright playwright install chromium firefox webkit
uv run --with playwright python3 /tmp/browser-check.py
```

Run project-owned Playwright suites in their own environment, using the browser revisions required by their dependency version. A `PLAYWRIGHT_BROWSERS_PATH` holds the browsers of one Playwright version, so never point another version's driver at it.

## Gather evidence

Reproduce the reported interaction at the relevant viewport and device scale. Wait for the content to render, then inspect the DOM and screenshots. Compare visuals under the same conditions, and inspect the images yourself.

For performance issues, capture a trace while reproducing the interaction. Check scripting, layout, paint, and compositing costs, and inspect GPU status if acceleration may be involved. Record the browser engine, headless mode, and rendering backend alongside the measurements so differences from the user's desktop browser remain clear.
