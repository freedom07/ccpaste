<div align="center">

<p>English | <a href="README.ko.md">한국어</a></p>

# ccpaste

**Claude Code terminal output → Rich text clipboard**

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple&logoColor=white)](https://github.com/freedom07/ccpaste)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/freedom07/ccpaste?include_prereleases)](https://github.com/freedom07/ccpaste/releases)
[![Build](https://github.com/freedom07/ccpaste/actions/workflows/build.yml/badge.svg)](https://github.com/freedom07/ccpaste/actions/workflows/build.yml)

Press <kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd> to convert copied terminal text into rich text that pastes beautifully everywhere.

[Installation](#installation) · [Usage](#usage) · [How It Works](#how-it-works) · [Contributing](#contributing)

</div>

---

## The Problem

Copy output from Claude Code (or any terminal) and paste it into Notion, Slack, or Google Docs. What you get:

- Markdown markers (`**`, `` ``` ``) shown as raw text
- ANSI escape codes (`[0m`, `[32m`) polluting the text
- All structure flattened into an unreadable wall of text
- Claude UI markers (⏺▶◼●) mixed in

**ccpaste** fixes this with a single keystroke.

## Demo

```
┌─────────────────────────────────────────────┐
│  Terminal (Cmd+C)                            │
│  **Bold**, `code`, - list items              │
│  ANSI colors, Claude markers ⏺              │
└──────────────┬──────────────────────────────┘
               │
         ⌘ + ⇧ + C
               │
               ▼
┌─────────────────────────────────────────────┐
│  Notion / Slack / Google Docs (Cmd+V)       │
│  Bold, code, • list items                   │
│  Clean, formatted rich text                  │
└─────────────────────────────────────────────┘
```

## Features

- **One keystroke** — <kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd> converts clipboard to rich text
- **ANSI stripping** — Removes all terminal color/style escape codes
- **Claude Code aware** — Strips UI markers (⏺▶◼●) automatically
- **GFM support** — Tables, strikethrough, autolinks, task lists via [cmark-gfm](https://github.com/github/cmark-gfm)
- **Box-drawing tables** — Converts Unicode box-drawing tables to Markdown tables
- **Inline CSS** — Dark-themed code blocks, styled tables, proper headings
- **Native macOS** — Menu bar app, no Electron, no dependencies to install
- **Lightweight** — < 2MB, launches in milliseconds

## Supported Apps

| App | Tables | Code Blocks | Lists | Bold/Italic | Blockquotes |
|-----|:------:|:-----------:|:-----:|:-----------:|:-----------:|
| Notion | ✅ | ✅ | ✅ | ✅ | ✅ |
| Google Docs | ✅ | ✅ | ✅ | ✅ | ✅ |
| Apple Mail | ✅ | ✅ | ✅ | ✅ | ✅ |
| Slack | ❌¹ | ✅ | ✅ | ✅ | ✅ |

<sup>¹ Slack does not support table paste — this is a Slack limitation, not ccpaste.</sup>

## Installation

### Quick Install (one line)

```bash
curl -sL https://github.com/freedom07/ccpaste/releases/latest/download/ccpaste.app.zip -o /tmp/ccpaste.zip && unzip -o /tmp/ccpaste.zip -d /Applications && rm /tmp/ccpaste.zip && xattr -cr /Applications/ccpaste.app
```

### Build from Source

```bash
git clone https://github.com/freedom07/ccpaste.git
cd ccpaste
bash build.sh
cp -r .build/release/ccpaste.app /Applications/
```

### From GitHub Releases

Download the latest `.app.zip` from [Releases](https://github.com/freedom07/ccpaste/releases), unzip, and drag to `/Applications`.

> **Note:** Since the app is not yet notarized, macOS may show a Gatekeeper warning.
> Right-click the app → "Open" → "Open" to bypass, or run:
> ```bash
> xattr -cr /Applications/ccpaste.app
> ```

### Uninstall

```bash
killall ccpaste; rm -rf /Applications/ccpaste.app
```

### Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9+ (for building from source)

## Usage

1. **Copy** text from terminal with <kbd>⌘</kbd><kbd>C</kbd>
2. **Convert** with <kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd>
3. **Paste** into any app with <kbd>⌘</kbd><kbd>V</kbd>

A toast notification at the bottom of your screen confirms the conversion:
- ✅ **Rich text ready** — success
- ❌ **No text in clipboard** — clipboard was empty

The app runs in the menu bar — look for the 📄 icon to access the menu or quit.

## How It Works

```
Cmd+Shift+C
    │
    ▼
ClipboardManager.readPlainText()
    │
    ▼
TerminalNormalizer.normalize()
    ├── Strip ANSI escape codes (CSI, OSC, SGR)
    ├── Remove Claude UI markers (⏺▶◼●)
    ├── Convert box-drawing tables → Markdown
    └── Normalize indentation
    │
    ▼
MarkdownConverter.toHTML()
    └── cmark-gfm with GFM extensions
    │
    ▼
HTMLStyler.applyStyles()
    ├── Code blocks: dark theme (#1e1e1e)
    ├── Inline code: light grey (#f5f5f5)
    ├── Tables: borders + padding
    ├── Blockquotes: left border
    └── Headings: bold + sized
    │
    ▼
ClipboardManager.writeRichText()
    └── NSPasteboard: .html + .string
    │
    ▼
Toast: "✅ Rich text ready"
```

### Architecture

```
Sources/ccpaste/
├── main.swift              # Entry point
├── AppDelegate.swift       # Menu bar + Carbon global hotkey + pipeline
├── TerminalNormalizer.swift # ANSI strip + Claude markers + box-drawing
├── MarkdownConverter.swift  # cmark-gfm wrapper (MD → HTML)
├── HTMLStyler.swift         # Inline CSS styling
├── ClipboardManager.swift   # NSPasteboard read/write
└── ToastWindow.swift        # Floating toast notification
```

### Key Technical Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Global hotkey | Carbon `RegisterEventHotKey` | No Accessibility permission needed |
| MD → HTML | [libcmark_gfm](https://github.com/KristopherGBaker/libcmark_gfm) | GFM tables, strikethrough, autolinks |
| Clipboard format | HTML + plain text | Universal app compatibility via NSPasteboard |
| Styling | Inline CSS | `<style>` blocks are stripped by most paste targets |
| App type | LSUIElement menu bar app | No dock icon, no window clutter |

## Troubleshooting

<details>
<summary><strong>Cmd+Shift+C doesn't work</strong></summary>

Another app may have registered this shortcut. Check System Settings → Keyboard → Keyboard Shortcuts for conflicts.
</details>

<details>
<summary><strong>Gatekeeper blocks the app</strong></summary>

The app is not yet notarized. Right-click → "Open" → "Open", or run:
```bash
xattr -cr /Applications/ccpaste.app
```
</details>

<details>
<summary><strong>Tables don't paste correctly in Slack</strong></summary>

Slack does not support HTML table paste. This is a Slack limitation. Tables will appear as plain text in Slack but render correctly in Notion, Google Docs, and Apple Mail.
</details>

<details>
<summary><strong>Menu bar icon not visible</strong></summary>

If you have many menu bar icons, ccpaste's icon may be hidden behind the notch. The hotkey (<kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd>) still works regardless.
</details>

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR.

## License

[MIT](LICENSE) © 2026 yun

## Acknowledgments

- [cmark-gfm](https://github.com/github/cmark-gfm) — GitHub Flavored Markdown parser
- [libcmark_gfm](https://github.com/KristopherGBaker/libcmark_gfm) — Swift wrapper for cmark-gfm
- Inspired by the pain of pasting Claude Code output into Notion

---

<div align="center">

**If ccpaste saves you time, consider giving it a ⭐**

</div>
