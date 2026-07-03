# macOS Menu Bar App: Claude Code Limits

## Context

Build a native macOS menu bar (top bar) app that surfaces Claude Code usage
limits at a glance, in the format:

```
4:10 [▁ bar ▁] 13% │ 2d 3h [▁ bar ▁] 3%
```

- Left group = the **5-hour** session window; right group = the **7-day** weekly window.
- The time is a **countdown remaining until reset** (`4:10` = 4h10m left; `2d 3h` = 2 days 3 hours left), not the reset clock time.
- The bar is a **very minimalist graphical progress bar** (real pixels, not unicode blocks).
- Monochrome by default (blends into the menu bar, adapts to light/dark); turns **amber >60%**, **red >80%** so a near-limit draws the eye.

Reference implementation for the data fetch exists in the user's dotfiles at
`~/dotfiles/.tmux/scripts/claude-usage.sh` (polls the same endpoint for the tmux
status bar). This app reimplements that fetch natively so it can draw crisp bars
and live-tick the countdown.

### Data source

- Token: `security find-generic-password -s "Claude Code-credentials" -w`, then
  decode `.claudeAiOauth.accessToken` from the returned JSON (decode in Swift).
- Request: `GET https://api.anthropic.com/api/oauth/usage`
  - `Authorization: Bearer <token>`
  - `anthropic-beta: oauth-2025-04-20`
- Response fields used: `five_hour.utilization`, `five_hour.resets_at`,
  `seven_day.utilization`, `seven_day.resets_at`. `resets_at` is ISO-8601 with
  microseconds + `+00:00` offset (e.g. `2026-07-03T11:09:59.839280+00:00`).
- Confirmed live values at plan time: 5h ≈ 14%, 7d ≈ 3%.

### Approach

Native Swift menu bar app compiled with `swiftc` into an app bundle — no Xcode
project. `LSUIElement` agent app (no Dock icon), one `NSStatusItem`, launched at
login via a LaunchAgent. No external dependencies — system Swift toolchain,
`security`, `URLSession` only.

All files live in the project root `~/Code/claude-code-limits/`.

---

### Task 1: Project scaffolding

Create the repository skeleton so later tasks have a stable structure.

- [x] `README.md` — one-paragraph description of the app plus placeholders for the
  Build and Install sections (filled in by later tasks).
- [x] `.gitignore` — ignore the built bundle (`ClaudeCodeLimits.app/`) and macOS
  cruft (`.DS_Store`).
- [x] Empty `main.swift` with just a top-of-file `import AppKit` and a `// TODO`
  marker so the file exists for later tasks to fill.

**Acceptance:** `README.md`, `.gitignore`, and `main.swift` exist at the project
root; `git status` shows them as new files; `swiftc -parse main.swift` succeeds.
- [x] `swiftc -parse main.swift` (skipped — Mac-only, no swiftc on Linux host)

---

### Task 2: Data model, keychain + API fetch

Implement the data layer in `main.swift`.

- [x] Define a `WindowUsage` struct/tuple holding `utilization: Double` and
  `resetsAt: Date`, and an app-state holder with optional `fiveHour` and
  `sevenDay` values plus a `hasLoaded` flag.
- [x] `readToken() -> String?`: shell out to
  `security find-generic-password -s "Claude Code-credentials" -w`, parse the
  returned JSON, return `.claudeAiOauth.accessToken`. Return `nil` on any failure.
- [x] `fetchUsage(completion:)`: build a `URLSession` `GET` to
  `https://api.anthropic.com/api/oauth/usage` with headers
  `Authorization: Bearer <token>` and `anthropic-beta: oauth-2025-04-20`. Decode
  `five_hour` and `seven_day` (`utilization`, `resets_at`). Parse `resets_at`
  with an ISO-8601 formatter tolerant of fractional seconds. On any failure
  (no token, network error, `error` key in JSON, decode failure) call completion
  with `nil` so the caller keeps the last good state.
- [x] Run the fetch off the main thread; the completion is invoked on the main thread.
- [x] host-run acceptance (temporary main printing utilizations) — skipped, no swiftc on Linux host

**Acceptance:** a temporary `main()` that calls `fetchUsage` and prints the two
utilizations compiles and, when run on the host, prints values matching the live
API (≈14% / ≈3%). Remove the temporary print before finishing.

---

### Task 3: Countdown formatting

Add pure formatting helpers to `main.swift` (no UI yet), so they are unit-checkable.

- [x] `formatFiveHour(_ remaining: TimeInterval) -> String`: `h:mm` (e.g. `4:10`);
  when under one hour, `0:mm`; clamp negatives to `0:00`.
- [x] `formatSevenDay(_ remaining: TimeInterval) -> String`: `Nd Nh` when ≥1 day,
  else `Nh Nm`, else `Nm`; clamp negatives to `0m`.
- [x] Both derive `remaining` from `resetsAt - Date()`.

**Acceptance:** a temporary driver prints correct strings for a spread of inputs
(e.g. 15010s → `4:10`; 183600s → `2d 3h`; 2700s → `0:45`; 800s → `13m`; negative
→ zero form). Remove the driver before finishing.

---

### Task 4: Menu bar rendering

Render the whole status item as a single `NSImage` so text and bars share the
pixel grid.

- [x] Layout per window, left→right: countdown text · progress bar · `NN%`; a thin
  `│` separates the 5h and 7d groups.
- [x] Bar: ~22×5px `NSBezierPath(roundedRect:)` track + rounded fill proportional to
  utilization. No border, no chrome.
- [x] Color: `NSColor.labelColor` at rest; the fill and the percent text switch to
  amber when utilization > 60 and red when > 80.
- [x] When everything is monochrome set `image.isTemplate = true` (so macOS tints for
  light/dark and menu-bar highlight); when a warning color is active, draw
  non-template so amber/red survives.
- [x] Font: system font at `NSFont.systemFontSize(for: .small)` / menu-bar size (~11pt).
- [x] No-data / no-token state renders a dim `∞`.
- [x] PNG harness acceptance (skipped — no swiftc on Linux host)

**Acceptance:** a function `renderStatusImage(state) -> NSImage` returns a
correctly sized image; a temporary harness writes one PNG at ~14%/3% and one at a
forced 85% and they visibly differ (monochrome vs red). Remove the harness before
finishing.

---

### Task 5: App lifecycle, status item, timers, menu

Wire the pieces into a running agent app in `main.swift`.

- [x] `NSApplication` with `.accessory` activation policy; an `AppDelegate` owning one
  `NSStatusItem` (variable length) whose `button.image` is set from
  `renderStatusImage`.
- [x] **Fetch timer** every 300s (fire once immediately on launch) → `fetchUsage`,
  update state on success, keep last good on failure, then redraw.
- [x] **Redraw timer** every 30s → recompute countdowns and redraw so the timer ticks.
- [x] Minimal dropdown `NSMenu`: two disabled info rows (`5h resets at <clock>`,
  `Weekly resets <day clock>` using a local-time formatter), a separator,
  `Refresh now` (triggers an immediate fetch), and `Quit`.
- [x] `swiftc main.swift -o /tmp/cclimits && /tmp/cclimits` acceptance (skipped — Mac-only, no swiftc on Linux host)

**Acceptance:** `swiftc main.swift -o /tmp/cclimits && /tmp/cclimits` shows the
item in the menu bar with ticking countdowns and aligned bars; the dropdown shows
correct reset times; `Refresh now` re-fetches; `Quit` exits.

---

### Task 6: build.sh — assemble the .app bundle

Create `build.sh` that produces a double-clickable/loadable app.

- [x] Compile: `swiftc main.swift -o ClaudeCodeLimits.app/Contents/MacOS/ClaudeCodeLimits`.
- [x] Generate `ClaudeCodeLimits.app/Contents/Info.plist` with `LSUIElement=true`,
  `CFBundleName=ClaudeCodeLimits`, `CFBundleExecutable=ClaudeCodeLimits`,
  `CFBundleIdentifier=ai.morox.cc-limits`, and a bundle version.
- [x] Create the `Contents/MacOS` directory tree as needed; make the script
  idempotent (safe to re-run).

**Acceptance:** `bash build.sh` exits 0 and produces `ClaudeCodeLimits.app`;
`open ClaudeCodeLimits.app` launches the menu bar item with no Dock icon.

---

### Task 7: LaunchAgent + README install docs

Make it run at login and document usage.

- [x] `ai.morox.cc-limits.plist` — LaunchAgent with `RunAtLoad=true`,
  `KeepAlive=true`, and `ProgramArguments` pointing at the built binary inside
  the app bundle (absolute path under the user's home).
- [x] Fill in `README.md`: **Build** (`bash build.sh`) and **Install**
  (`cp` the plist to `~/Library/LaunchAgents/`, `launchctl load` it; `unload` to
  stop) sections, plus a note that it reads the Claude Code keychain credential.

**Acceptance:** copying the plist to `~/Library/LaunchAgents/` and running
`launchctl load` starts the app; `launchctl unload` stops it; README steps are
accurate.
