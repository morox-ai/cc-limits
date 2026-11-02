# AGENTS.md

Project guidance for coding agents working in this repository.

## Project overview

ClaudeCodeLimits is a native macOS menu bar app written in a single Swift source file (`main.swift`). It shows Claude Code and Codex usage limits by reading the Claude Code OAuth credential from the macOS keychain and the Codex credential from `~/.codex/auth.json`, then polling each service's usage endpoint.

There is no Xcode project and no external dependency manager. The app is built directly with the system Swift toolchain.

## Important files

- `main.swift` — application source code.
- `build.sh` — compiles `main.swift` and assembles `ClaudeCodeLimits.app`.
- `README.md` — user-facing build/install instructions.
- `ai.morox.cc-limits.plist` — LaunchAgent config for running the app at login.
- `ClaudeCodeLimits.app/` — generated build artifact; do not edit directly.
- `site/` — static website with no build step, deployed by `.github/workflows/pages.yml`. `PRODUCT.md` and `DESIGN.md` govern it.
- `packaging/homebrew/cc-limits.rb` — draft Homebrew formula that builds from source.

## Build and run

Use the repository script:

```sh
bash build.sh
```

Run the menu bar app with:

```sh
open ClaudeCodeLimits.app
```

If validating that it launched:

```sh
pgrep -fl ClaudeCodeLimits
```

If rebuilding while the app is already running, stop the existing process first:

```sh
pkill -x ClaudeCodeLimits || true
bash build.sh
open ClaudeCodeLimits.app
```

## Development notes

- Keep the app dependency-free unless explicitly asked otherwise.
- Prefer simple AppKit/Foundation APIs that compile with the system Swift toolchain.
- `ClaudeCodeLimits.app/` is generated and ignored by git; change `main.swift` or `build.sh` instead.
- Preserve the app as an `LSUIElement` menu bar utility with no Dock icon unless the user asks for a different behavior.
- The app depends on the macOS keychain item named `Claude Code-credentials` and on `~/.codex/auth.json`; avoid logging tokens or credential payloads.
- Network calls should remain asynchronous and UI updates should happen on the main queue.

## Testing / verification

There is currently no automated test suite. For changes, at minimum:

1. Run `bash build.sh`.
2. Launch with `open ClaudeCodeLimits.app`.
3. Confirm the process is running with `pgrep -fl ClaudeCodeLimits`.
4. For UI changes, visually inspect the menu bar item and menu behavior.
