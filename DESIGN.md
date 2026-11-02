---
name: cc-limits
description: A native macOS menu bar app for Claude Code and Codex limits, presented as itself on a cool Apple-style page.
colors:
  bg: "#f5f5f7"
  surface: "#ffffff"
  on-dark: "#ffffff"
  text: "#1d1d1f"
  text-body: "#424245"
  text-2: "#6e6e73"
  text-4: "#aeaeb2"
  hairline: "rgba(0, 0, 0, 0.07)"
  track: "#e8e8ed"
  accent: "#0071e3"
  accent-link: "#0066cc"
  amber: "#d99900"
  red: "#db3833"
  graphite: "#17181b"
  nav-glass: "rgba(245, 245, 247, 0.72)"
  menubar-glass: "rgba(30, 32, 36, 0.5)"
  menu-glass: "rgba(44, 46, 50, 0.72)"
  terminal-tint: "rgba(16, 17, 19, 0.86)"
typography:
  display:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "clamp(46px, 8vw, 88px)"
    fontWeight: 700
    lineHeight: 1.04
    letterSpacing: "-0.04em"
  headline:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "clamp(32px, 5vw, 52px)"
    fontWeight: 700
    lineHeight: 1.08
    letterSpacing: "-0.035em"
  lede:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "clamp(18px, 2.4vw, 22px)"
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: "-0.01em"
  section-lede:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "clamp(17px, 2vw, 19px)"
    fontWeight: 400
    lineHeight: 1.5
  title:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "-0.01em"
  body:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.55
  body-small:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "15.5px"
    fontWeight: 400
    lineHeight: 1.55
  label:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "13px"
    fontWeight: 400
  control:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "13px"
    fontWeight: 600
  code:
    fontFamily: "ui-monospace, 'SF Mono', Menlo, monospace"
    fontSize: "clamp(12px, 1.5vw, 13.5px)"
    fontWeight: 400
    lineHeight: 1.7
  status:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', sans-serif"
    fontSize: "11px"
    fontWeight: 400
    lineHeight: 1
    fontFeature: "tnum"
rounded:
  pill: "999px"
  circle: "50%"
  chip: "6px"
  thumb: "12px"
  card: "18px"
  panel: "22px"
  hero: "26px"
spacing:
  pad-x: "22px"
  section: "clamp(64px, 10vw, 128px)"
  block-head: "clamp(26px, 4vw, 40px)"
  split-offset: "clamp(24px, 3.4vw, 36px)"
  split-gap: "clamp(20px, 4vw, 48px)"
  panel-x: "clamp(16px, 3vw, 28px)"
  max-read: "720px"
  max-grid: "1080px"
  max-stage: "1240px"
components:
  nav:
    backgroundColor: "{colors.nav-glass}"
    textColor: "{colors.text}"
    height: "54px"
  nav-pill:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-dark}"
    typography: "{typography.control}"
    rounded: "{rounded.pill}"
    padding: "0 14px"
    height: "32px"
  nav-pill-hover:
    backgroundColor: "{colors.accent-link}"
  cmd:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    rounded: "{rounded.pill}"
    padding: "3px 3px 3px 18px"
    height: "50px"
  cmd-inset:
    backgroundColor: "{colors.bg}"
    textColor: "{colors.text}"
    rounded: "{rounded.pill}"
    padding: "3px 3px 3px 18px"
    height: "50px"
  cmd-dark:
    backgroundColor: "rgba(255, 255, 255, 0.1)"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.pill}"
    padding: "3px 3px 3px 18px"
    height: "50px"
  copy-button:
    textColor: "{colors.text-2}"
    rounded: "{rounded.circle}"
    size: "44px"
  copy-button-hover:
    backgroundColor: "rgba(0, 0, 0, 0.05)"
    textColor: "{colors.text}"
  panel:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    rounded: "{rounded.panel}"
  segmented:
    backgroundColor: "rgba(127, 127, 127, 0.24)"
    rounded: "{rounded.pill}"
    padding: "3px"
    height: "36px"
  segmented-thumb:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    rounded: "{rounded.pill}"
  code-block:
    backgroundColor: "{colors.graphite}"
    textColor: "rgba(255, 255, 255, 0.66)"
    typography: "{typography.code}"
    rounded: "{rounded.card}"
    padding: "20px 22px"
  desktop-stage:
    backgroundColor: "{colors.graphite}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.hero}"
    height: "clamp(440px, 34vw, 480px)"
  close-band:
    backgroundColor: "{colors.graphite}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.hero}"
    padding: "clamp(56px, 9vw, 104px) 22px"
  menubar:
    backgroundColor: "{colors.menubar-glass}"
    textColor: "{colors.on-dark}"
    height: "40px"
  menu:
    backgroundColor: "{colors.menu-glass}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.thumb}"
    padding: "6px"
    width: "470px"
  menu-action-hover:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.chip}"
  status-item:
    textColor: "{colors.on-dark}"
    typography: "{typography.status}"
---

# Design System: cc-limits

## Overview

**Creative North Star: "The Product Is the Page"**

This is a literal instruction, not a metaphor. The tiny status item and its menu are drawn at their real proportions and the page around them is quiet enough to let a 22 by 5 bar be the most interesting thing on it. The style descends from the user's `apple-liquid-glass` skill: cool ground, white panels, hairlines, system San Francisco, frost only where layers overlap. Where the build departs from that lineage, the build is what this file records.

The page runs on two grounds. The cool light ground carries reading and white panels; graphite carries the product, its code and the closing command. Density is low and copy is short, so a section is usually one heavy headline, one sentence and one panel. Hierarchy comes from size, weight and grey before it comes from color.

Themed and metaphorical worlds were rejected outright by the user, including parking meters, departure boards and retro stacks. New surfaces extend this literal, product-first system rather than dressing the product up as something else.

**Key Characteristics:**
- Real product proportions, shown at scale on a graphite stage.
- Cool #f5f5f7 ground, white unified panels, hairline rows.
- One system sans at heavy weights with tight negative tracking.
- Blue for action only; amber and red belong to the app's thresholds.
- Glass only where layers truly overlap, with solid fallbacks.

## Colors

A cool greyscale skeleton with a single blue for action, one graphite for the product, and two warning colors borrowed from the app itself.

### Primary
- **Action Blue** (#0071e3): The Install pill, focus rings, the copied checkmark on light grounds and the highlighted menu action. It is also the 20% selection tint.
- **Link Blue** (#0066cc): Inline text links and the hover state of the Install pill.

### Secondary
- **Threshold Amber** (#d99900): The status item past 60% usage, nowhere else. Same value as `amberColor` in `main.swift`.
- **Threshold Red** (#db3833): The status item past 80% usage, nowhere else. Same value as `redColor` in `main.swift`.

### Neutral
- **Cool Ground** (#f5f5f7): Page background and the inset command pill inside a panel.
- **Panel White** (#ffffff): Panels and the raised command pill; also the white text and thumb color on dark and accent grounds.
- **Ink** (#1d1d1f): Headlines, row titles and inline code.
- **Body Grey** (#424245): Asides, table cells and FAQ answers.
- **Quiet Grey** (#6e6e73): Ledes, captions, table headers and footer. It holds 4.66:1 on the ground, so it stays at this step or darker for any text.
- **Tick Grey** (#aeaeb2): The 60 and 80 tick marks on the slider track only; never text.
- **Track Grey** (#e8e8ed): Slider track and the Light appearance of the status stage.
- **Hairline** (rgba(0, 0, 0, 0.07)): Every divider between rows and the scrolled nav edge.
- **Graphite** (#17181b): Desktop stage, status lab, code block and closing band.
- **Glass tints**: Nav (rgba(245, 245, 247, 0.72)), simulated menu bar (rgba(30, 32, 36, 0.5)), simulated menu (rgba(44, 46, 50, 0.72)), simulated terminal (rgba(16, 17, 19, 0.86), translucent with no blur).

### Named Rules
**The Threshold Colors Rule.** Amber and red belong to the app. They appear only on a status item group, past 60% and past 80%, exactly as `warningColor` in `main.swift` assigns them. They are not the page's warning, error or highlight colors, and their values do not change for the page's convenience.

**The One Blue Rule.** Blue means action and its direct feedback. No decorative blue, no blue headings, no second accent hue.

**The Graphite Stage Rule.** Dark is a stage for the product and its commands, not a theme. The page itself is light (`color-scheme: light`); graphite appears as bounded rounded regions on it.

## Typography

**Display Font:** System San Francisco (`-apple-system`, with SF Pro and Helvetica Neue fallbacks)
**Body Font:** The same system stack
**Label/Mono Font:** `ui-monospace` (with SF Mono and Menlo fallbacks), for commands, code and terminal text only

**Character:** The app's own typeface, because the product is a macOS menu bar item and SF is what it renders in. Character comes from size and tracking: very large, bold and tight at the top, ordinary and grey below. `font-optical-sizing: auto` is on.

### Hierarchy
- **Display** (700, clamp(46px, 8vw, 88px), 1.04, -0.04em): The single page headline, centered and balanced.
- **Headline** (700, clamp(32px, 5vw, 52px), 1.08, -0.035em): Section headlines, left aligned; centered in the closing band.
- **Lede** (400, clamp(18px, 2.4vw, 22px), 1.45, -0.01em): The one sentence under Display, in Quiet Grey, max 34em.
- **Section lede** (400, clamp(17px, 2vw, 19px), 1.5): The sentence under a Headline, in Quiet Grey, inside a 640px head.
- **Title** (600, 15 to 16px, 1.4, -0.01em): Row names in panels: step names, FAQ questions, table row heads, slider labels.
- **Body** (400, 17px, 1.55): Asides and running text. Copy here is short, so this is tighter than the lineage's long-form 1.85.
- **Body small** (400, 15.5px, 1.55): Table cells and FAQ answers.
- **Label** (400 to 500, 13 to 13.5px): Captions, table headers, meta line, footer, nav link. Sentence case, never tracked uppercase.
- **Control** (600, 13px; segmented at 12.5px): Text inside pills.
- **Code** (400, clamp(12px, 1.5vw, 13.5px), 1.7): Code blocks. The terminal runs at 14px, command pills at clamp(12px, 3.3vw, 14.5px), inline code at 0.9em.
- **Status** (400, 11 units, 1, tabular): The status item, matching the app's small system font.

### Named Rules
**The Bigger Is Tighter Rule.** Tracking tightens with size: -0.04em at Display, -0.035em at Headline, -0.01em at Title and Lede, none at Body. Leading falls the same way.

**The Tabular Numbers Rule.** Anything that changes while being read (status item, menu rows, clock, slider value) uses tabular numerals so nothing jitters.

## Layout

A single centered column system: 720px for reading (hero copy), 1080px for sections, with 22px side padding. The product stage alone breaks out, to 1240px. Sections are separated by a large rhythm of clamp(64px, 10vw, 128px), much wider than the lineage's section gap, because each section is one idea. A section head runs to 640px and sits clamp(26px, 4vw, 40px) above its panel. Asides under a panel sit in an equal two-column split with a clamp(20px, 4vw, 48px) gap, clamp(24px, 3.4vw, 36px) below it. Panel rows pad 16 to 28px horizontally on a fluid clamp.

Sizes are fluid through `clamp()`; breakpoints only restructure. At 1100px the closing band gains side margins. At 860px install steps stack, the simulated menu narrows and the terminal widens to fill the stage. At 680px every split collapses to one column, the table turns into labeled blocks, secondary links and menu bar chrome hide, the slider divider turns horizontal and the desktop stage grows to 536px with its terminal docked to the bottom.

## Elevation & Depth

A hybrid of soft two-layer shadow and tonal grounds. Light surfaces lift very gently off the cool ground; graphite regions rely on tone rather than lift. Translucent frost is reserved for chrome that sits over other content, and `prefers-reduced-transparency` swaps every blurred layer for a solid (nav to Cool Ground, menu bar to #2a2c30, menu to #2c2e32). `prefers-contrast: more` makes the nav white and the menu black and raises Quiet Grey text to Ink.

### Shadow Vocabulary
- **Card** (`box-shadow: 0 1px 2px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05)`): The raised command pill.
- **Panel** (`box-shadow: 0 1px 3px rgba(0,0,0,0.05), 0 14px 40px rgba(0,0,0,0.05)`): White panels and the desktop stage.
- **Overlay** (`box-shadow: 0 2px 8px rgba(0,0,0,0.1), 0 30px 80px rgba(0,0,0,0.24)`): The simulated menu.
- **Window** (`box-shadow: 0 2px 8px rgba(0,0,0,0.2), 0 24px 60px rgba(0,0,0,0.35)`): The simulated terminal, heavier because it floats on graphite.
- **Scroll edge** (`box-shadow: 0 1px 12px rgba(0,0,0,0.04)`): The nav, only once scrolled past 8px.
- **Control thumbs** (`box-shadow: 0 1px 3px rgba(0,0,0,0.12)` segmented; `0 1px 3px rgba(0,0,0,0.25), 0 3px 10px rgba(0,0,0,0.12)` slider): Small raised parts of a control.

### Named Rules
**The Glass Is Seasoning Rule.** Frost (saturate 180% with 20px blur, 28px on the menu) goes only on the sticky nav and the simulated menu bar and menu, the places where content truly passes underneath. Panels, rows and code stay solid.

**The Two-Layer Rule.** Anything that floats as a surface gets a tight contact layer plus a soft spread layer. Only the scroll edge and the segmented thumb are single and soft; no shadow is ever hard or offset.

**The Scroll Edge Rule.** The nav sits flush on the ground at the top of the page. Its hairline and shadow appear only once content is beneath it.

## Shapes

Generously rounded, in fixed tiers that grow with surface size: full pill (999px) for commands, buttons and tracks; circles (50%) for the copy button and slider thumb; 6px for small targets inside chrome such as menu items and the status button; 12px for the simulated terminal and menu; 18px for code blocks and the mobile stage; 22px for panels; 26px for the hero stage and closing band. Panels clip their rows. Borders are rare: dividers are hairlines between rows, and 1px light strokes appear only on translucent dark layers.

## Components

### Buttons
Quiet, tactile pills that answer on press.
- **Shape:** Full pill (999px); icon button is a circle.
- **Primary:** The Install pill, Action Blue with white text, 32px tall and 14px side padding. An invisible extension brings its hit area to 44px.
- **Hover / Focus:** Hover darkens to Link Blue over 0.15s. Press scales to 0.97 in 0.1s. Focus everywhere is a 2px Action Blue outline, offset 2px.
- **Copy button:** A 44px transparent circle with an 18px stroked icon in Quiet Grey. Hover fills with 5% black and darkens the icon; press scales to 0.92. On success the icon crossfades to a checkmark for 1.6s and a live region announces it. If the clipboard fails, the command is selected and the fallback is announced.

### Command pill
The primary call to action of the system: a real command with a copy button, not a button that describes one. Monospace on a 50px pill, three variants by ground: raised white with Card shadow on the page, inset Cool Ground with no shadow inside a panel, translucent white with a 12% inset ring on graphite. Long commands scroll inside the pill and never wrap.

### Cards / Containers
One kind: the unified panel.
- **Corner Style:** 22px, clipped.
- **Background:** Panel White.
- **Shadow Strategy:** Panel shadow.
- **Border:** None outside; Hairline between rows.
- **Internal Padding:** Held by the rows, not the panel, at 14 to 20px vertically and 16 to 28px horizontally.

### Navigation
A 54px sticky frosted bar: brand mark and name at left (22px mark, 15px at 650, -0.01em), one quiet text link and the Install pill at right. The text link hides at 680px; the pill stays.

### Status item
The signature component and the reason the page exists. Every dimension scales from one unit (`--u`) using the app's own numbers: 22 by 5 bar, 4 gap, 6 group gap, 11 type. Scale the unit and nothing else (1.55px in the hero menu bar, up to 4px in the lab). It inherits a white or Ink label by appearance, and a group takes amber or red through `currentColor`, tinting bar, percentage and reset time together over 0.25s. The separator is the app's own `│` at 50% opacity.

### Slider
Native range input with a 6px pill track and a 26px white thumb that scales to 1.08 on press, in a 44px tall hit area. Tick marks at exactly 60% and 80% are compensated for thumb width, so the thumb center and the threshold agree.

### Segmented control
A pill trough of 24% neutral grey with a sliding white thumb, 0.25s on the quart ease-out. It sits on either ground, so its trough is neutral, and each 30px button extends to a 44px hit area.

### Simulated desktop
A 26px graphite region with two soft radial wallpaper lights, holding a glass menu bar, a terminal window and the menu. The menu materializes with opacity, scale and blur moving together: 0.4s on the spring curve in, 0.26s out, anchored toward its trigger, and Escape or an outside click closes it. Menu rows are 72% white; the hovered action fills with Action Blue. Simulations are captioned as simulated with demo numbers.

### Code block
Graphite, 18px radius, 20 by 22px padding, monospace at 1.7. Syntax uses white weight rather than hue: keywords and numbers at full white 600, types at 86%, the rest at 66%. It is real source, quoted from the app.

## Do's and Don'ts

### Do:
- **Do** show the product at its real proportions and drive it live where possible, scaling only the status item's unit.
- **Do** group sibling content on one white panel with hairline rows.
- **Do** make the command itself the call to action, in a pill with a copy button.
- **Do** give every page control a 44px hit area, extending invisibly when the visual is smaller.
- **Do** pair every frosted layer with solid fallbacks for reduced transparency and increased contrast.
- **Do** label simulated product states and demo numbers as such.
- **Do** keep real icons as inline stroked SVG, 1.75 to 2.25 weight, with round caps and joins. Text glyphs are fine only where the product or the terminal really prints them (`│`, `∞`, `⌘R`, `●`).

### Don't:
- **Don't** build themed or metaphorical worlds around the product; the user rejected them.
- **Don't** use amber (#d99900) or red (#db3833) anywhere but a status item past its threshold, and don't retune them away from the app's values.
- **Don't** introduce new hues, a warm or cream ground, or a second accent.
- **Don't** use gradient washes on page grounds or controls. The desktop stage's two wallpaper lights are the only atmosphere; the slider track's gradient only draws ticks.
- **Don't** put frost on panels, rows or code blocks.
- **Don't** use hard or offset shadows.
- **Don't** set text in Tick Grey (#aeaeb2) or lighter on the light ground.
- **Don't** use monospace outside commands, code and terminal output.
