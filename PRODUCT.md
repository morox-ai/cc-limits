# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

The product itself is a native macOS menu bar app. This record governs its website, which is a static web page.

## Stack

Static HTML/CSS/JS with no dependencies and no build step, in `site/`, hosted on GitHub Pages at `cc-limits.morox.ai`. User's choice.

## Users

Developers on a Mac who use Claude Code, Codex, or both on a subscription and regularly hit their usage limits. They live in a terminal, usually mid-task, and find out they are out of quota when the agent stops. Their job: know how much is left and when it resets without leaving what they are doing.

## Product Purpose

cc-limits keeps Claude Code and Codex usage limits visible in the macOS menu bar, so a limit stops being a surprise. Success: a developer installs it in one command and never again gets cut off without warning.

## Positioning

Two providers, one menu bar item, zero setup. It reuses the credentials already on the machine, so there is no account, no API key and no configuration. The whole app is one Swift source file with no dependencies, small enough to read before trusting it with a credential.

## Operating Context

- Lives in the menu bar as an `LSUIElement` with no Dock icon.
- Shown at a glance while working in a terminal; the menu is opened only for the weekly detail.
- Starts at login and stays running.

## Capabilities and Constraints

- Menu bar shows Claude Code on the left and Codex on the right, each with a 22×5 pt bar, a percentage and the 5-hour window's reset time, split by `│`.
- Menu adds the 7-day window for both, with "resets in" and "at" times, plus Refresh now (⌘R) and Quit (⌘Q).
- Bars are monochrome and follow the menu bar's appearance; above 60% they turn amber, above 80% red.
- A dim `∞` means a provider has not loaded yet: signed out, an API key instead of a ChatGPT login, or keychain access not granted.
- An expired or missing window counts as 0%.
- Polls every 5 minutes, redraws every 30 seconds.
- Reads the Claude Code OAuth token from the keychain item `Claude Code-credentials` and the Codex token from `~/.codex/auth.json`. The Codex token is never refreshed by the app.
- Talks only to `api.anthropic.com` and `chatgpt.com`. No analytics, no server of its own.
- The usage endpoints are not public documented APIs and can change without notice.
- Requires macOS 12 or newer and the Xcode Command Line Tools.
- On first launch macOS may ask for keychain access; "Always Allow" lets it run unattended.

### Open decisions

- Install path: a formula in `morox-ai/homebrew-tap` (`brew install morox-ai/tap/cc-limits`) that builds tagged releases from source, which needs no Developer ID signing or notarization. The repository `morox-ai/cc-limits` is public under MIT.

## Brand Commitments

- Names in use: `CCLimits` (app bundle), `cc-limits` (command and public name). The user reviewed renaming and kept `cc-limits`.
- Published by the user's company, Morox (`morox-ai` on GitHub, `morox.ai`).
- Website voice: English, short and dry, with the irony of someone a limit cut off mid-refactor.
- Standing preference: product-first presentation in the user's `apple-liquid-glass` style. Metaphorical or themed worlds (parking meters, departure boards, retro stacks) were rejected.

## Evidence on Hand

- Real menu bar captures: `img/screen-61.png` (61%, amber, resets 5:10) and `img/screen-82.png` (82%, red, resets 5:10). Low resolution, about 220×75 px.
- Source code in `main.swift`, 546 lines.
- No users, stars, testimonials, press, benchmarks or pricing exist. Do not fabricate them.

## Product Principles

- Show the number, then get out of the way.
- Own nothing: no account, no server, no settings.
- Readable enough to audit in one sitting, because it touches credentials.
- Quiet until it matters: monochrome until a threshold is crossed.
