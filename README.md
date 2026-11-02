# ClaudeCodeLimits

A native macOS menu bar app that surfaces Claude Code and Codex usage limits at a
glance. The menu bar shows two identical bars, Claude Code on the left and Codex
on the right, each with a minimalist progress bar, a percentage, and the reset
time of the 5-hour window. The menu adds the 7-day weekly window for both. Bars
stay monochrome to blend into the menu bar and turn amber/red as you approach a
limit. It reads the Claude Code OAuth credential from the macOS keychain and the
Codex credential from `~/.codex/auth.json`, then polls each service's usage
endpoint.

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
sed "s|/Users/you/Code/cc-limits|$PWD|" ai.morox.cc-limits.plist > ~/Library/LaunchAgents/ai.morox.cc-limits.plist
launchctl load ~/Library/LaunchAgents/ai.morox.cc-limits.plist
```

Run this from the repository root. It points the agent at the app in your checkout.

To stop it:

```sh
launchctl unload ~/Library/LaunchAgents/ai.morox.cc-limits.plist
```

The app reads the Claude Code OAuth credential from the macOS keychain (the
`Claude Code-credentials` generic password) to query the Anthropic usage
endpoint. On first launch macOS may prompt to allow keychain access.

Because the LaunchAgent starts the app via `launchd`, the first keychain prompt
can appear in a non-interactive context. If the menu bar item stays on the dim
`∞` placeholder, launch the app once manually (`open ClaudeCodeLimits.app`) and
choose "Always Allow" on the keychain prompt so it can read the credential
unattended thereafter.

Codex limits require signing in with `codex login` using a ChatGPT account, with
credentials stored in `~/.codex/auth.json`. The app never refreshes the Codex
token itself, so it picks up the token Codex last saved. If you are signed out or
use an API key, the Codex side stays on the `∞` placeholder.
