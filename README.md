# ClaudeCodeLimits

A native macOS menu bar app that surfaces Claude Code usage limits at a glance —
the 5-hour session window and the 7-day weekly window, each shown as a countdown
until reset, a minimalist graphical progress bar, and a percentage. It stays
monochrome to blend into the menu bar and turns amber/red as you approach a
limit. It reads the Claude Code OAuth credential from the macOS keychain and
polls the Anthropic usage endpoint.

## Build

Requires macOS 12 (Monterey) or newer and the system Swift toolchain (Xcode
Command Line Tools) — no Xcode project and no external dependencies.

```sh
bash build.sh
```

This compiles `main.swift` and assembles `ClaudeCodeLimits.app` at the project
root. The script is idempotent — re-run it to rebuild after changes. Double-click
the bundle (or `open ClaudeCodeLimits.app`) to launch the menu bar item; it has no
Dock icon.

## Terminal launcher

The repository includes a `cc-limits` launcher script. From the repository root:

```sh
./cc-limits
```

To make `cc-limits` available from any terminal directory, symlink it into a
folder on your `PATH`:

```sh
ln -sf "$PWD/cc-limits" /opt/homebrew/bin/cc-limits
```

If you do not use Homebrew on Apple Silicon, choose another writable `PATH`
directory such as `~/.local/bin` or `/usr/local/bin`.

Then launch the app with:

```sh
cc-limits
```

Use `cc-limits --rebuild` to rebuild before launching, or
`cc-limits --foreground` to run the app executable in the current terminal.

## Install

Install as a LaunchAgent so it starts at login and stays running:

```sh
cp ai.morox.cc-limits.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/ai.morox.cc-limits.plist
```

To stop it:

```sh
launchctl unload ~/Library/LaunchAgents/ai.morox.cc-limits.plist
```

The `ProgramArguments` path in the plist assumes the repository lives at
`~/Code/cc-limits/`. If you cloned it elsewhere, edit that path to point
at `ClaudeCodeLimits.app/Contents/MacOS/ClaudeCodeLimits` inside your checkout
before loading.

The app reads the Claude Code OAuth credential from the macOS keychain (the
`Claude Code-credentials` generic password) to query the Anthropic usage
endpoint. On first launch macOS may prompt to allow keychain access.

Because the LaunchAgent starts the app via `launchd`, the first keychain prompt
can appear in a non-interactive context. If the menu bar item stays on the dim
`∞` placeholder, launch the app once manually (`open ClaudeCodeLimits.app`) and
choose "Always Allow" on the keychain prompt so it can read the credential
unattended thereafter.
