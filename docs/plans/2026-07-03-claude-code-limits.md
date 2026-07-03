# macOS Menu Bar App: Claude Code Limits

## Context

Build a native macOS menu bar (top bar) app that surfaces Claude Code
usage limits at a glance, in the format:

```
4:10 [▁ bar ▁] 13% │ 2d 3h [▁ bar ▁] 3%
```

- Left group = the **5-hour** session window; right group = the **7-day** weekly window.
- The time is a **countdown remaining until reset** (`4:10` = 4h10m left; `2d 3h` = 2 days 3 hours left), not the reset clock time.
- The bar is a **very minimalist graphical progress bar** (real pixels, not unicode blocks).
- Monochrome by default (blends into the menu bar, adapts to light/dark); turns **amber >60%**, **red >80%** so a near-limit draws the eye.

Reference implementation for the data fetch already exists in the user's dotfiles
at `~/dotfiles/.tmux/scripts/claude-usage.sh` (polls the same endpoint for the
tmux status bar). This app reimplements that fetch natively so it can draw crisp
bars and live-tick the countdown.

## Approach (decided)

Native Swift menu bar app compiled with `swiftc` into an app bundle — no Xcode
project. `LSUIElement` agent app (no Dock icon), one `NSStatusItem`, launched at
login via a LaunchAgent. Chosen over a SwiftBar/xbar plugin because it needs no
third-party host app and is the only option giving true graphical progress bars.

## Data source

- Token: `security find-generic-password -s "Claude Code-credentials" -w`, then
  decode `.claudeAiOauth.accessToken` from the returned JSON (decode in Swift).
- Request: `GET https://api.anthropic.com/api/oauth/usage`
  - `Authorization: Bearer <token>`
  - `anthropic-beta: oauth-2025-04-20`
- Response fields used: `five_hour.utilization`, `five_hour.resets_at`,
  `seven_day.utilization`, `seven_day.resets_at`. `resets_at` is ISO-8601 with
  microseconds + `+00:00` offset (e.g. `2026-07-03T11:09:59.839280+00:00`).
- Confirmed live values at plan time: 5h ≈ 14%, 7d ≈ 3%.

## Architecture

Single `main.swift`. State = two `(utilization: Double, resetsAt: Date)` pairs,
plus a "have we ever loaded" flag.

Two timers:
- **Fetch timer — every 300s:** keychain → `URLSession` request → decode → update
  state. On any failure (no token, network error, `error` in JSON) keep the last
  good state so the bar never blanks.
- **Redraw timer — every 30s:** recompute countdown (`resetsAt - Date()`) and
  repaint. Keeps `4:10` ticking without hammering the API.

Fetch runs off the main thread; UI updates dispatched back to main.

Countdown formatting:
- 5h window: `h:mm` (e.g. `4:10`); if <1h, `0:mm`.
- 7d window: `Nd Nh` when ≥1 day, else `Nh Nm`, else `Nm`.
- Never-loaded / no token: dim `∞` fallback.

## Rendering

Draw the entire status item as one `NSImage` so text + bars share the pixel grid.
Per window, left→right: countdown text · progress bar · `NN%`; a thin `│`
separates the two groups.

- Bar: ~22×5px rounded-rect track + rounded fill (`NSBezierPath` roundedRect).
  No border, no chrome.
- Color: system menu-bar label color at rest; fill + percent switch to amber
  (>60%) and red (>80%). Thresholds 60/80.
- Set `image.isTemplate = true` when fully monochrome so macOS tints for
  light/dark + highlight; when a warning color is active, draw non-template so
  amber/red survives.
- Font: system font ~11pt (`NSFont.menuBarFont` size).

Dropdown menu (minimal):
- `5h resets at <clock>` (disabled info row)
- `Weekly resets <day clock>` (disabled info row)
- separator
- `Refresh now` → triggers immediate fetch
- `Quit`

## Files (all in project root, `~/Code/claude-code-limits/`)

- `main.swift` — the app (~250 lines).
- `build.sh` — `swiftc main.swift -o …`, assemble `ClaudeCodeLimits.app/Contents/`
  (`MacOS/` binary + generated `Info.plist` with `LSUIElement=true`,
  `CFBundleName`, bundle id `ai.morox.cc-limits`).
- `ai.morox.cc-limits.plist` — LaunchAgent: `RunAtLoad=true`,
  `KeepAlive=true`, `ProgramArguments` → the built binary.
- `README.md` — build + `launchctl load/unload` instructions.
- `.gitignore` — ignore the built `ClaudeCodeLimits.app/` bundle (build artifact).

No external dependencies — system Swift toolchain, `security`, `URLSession` only.

## Verification

1. `bash build.sh` — compiles cleanly and produces `ClaudeCodeLimits.app`.
2. Launch the binary directly; confirm the menu bar shows `~14%` / `~3%` with
   ticking countdowns and aligned bars.
3. Temporarily hardcode a high utilization (e.g. 85%) to confirm amber/red +
   the template→non-template toggle; revert.
4. Open the dropdown: reset times correct, `Refresh now` re-fetches, `Quit` exits.
5. `cp` plist to `~/Library/LaunchAgents/`, `launchctl load`; confirm it starts
   and survives a re-login.
