# ccpaste

**Claude Code terminal output → Rich text clipboard for macOS.**

Press `Cmd+Shift+C` to convert copied terminal text (with markdown, ANSI codes, Claude UI markers) into rich text that pastes beautifully into Notion, Slack, Google Docs, and Apple Mail.

## Install

```bash
# Build from source
git clone https://github.com/freedom07/ccpaste.git
cd ccpaste
bash build.sh
cp -r .build/release/ccpaste.app /Applications/
```

## How it works

1. Copy text from terminal with `Cmd+C`
2. Press `Cmd+Shift+C` (ccpaste converts it to rich text)
3. Paste into Notion/Slack/Google Docs with `Cmd+V`

### Pipeline

```
Clipboard plain text
  → Strip ANSI escape codes
  → Remove Claude UI markers (⏺▶◼●)
  → Convert box-drawing tables → Markdown tables
  → Markdown → HTML (cmark-gfm)
  → Apply inline CSS styles
  → Write HTML + plain text to clipboard
```

## Supported apps

| App | Tables | Code blocks | Lists | Bold/Italic |
|-----|--------|-------------|-------|-------------|
| Notion | ✓ | ✓ | ✓ | ✓ |
| Google Docs | ✓ | ✓ | ✓ | ✓ |
| Apple Mail | ✓ | ✓ | ✓ | ✓ |
| Slack | ✗ (Slack limitation) | ✓ | ✓ | ✓ |

## Requirements

- macOS 13.0+
- Swift 5.9+

## License

MIT
