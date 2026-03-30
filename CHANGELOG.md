# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-03-30

### Changed
- Hotkey only activates when a terminal app is focused (Terminal, iTerm2, Ghostty, Warp, Hyper, WezTerm, Kitty, Alacritty)
- No longer intercepts `Cmd+Shift+C` in browsers and other apps (e.g., Chrome Inspect Element, Cursor external terminal)

## [1.0.0] - 2026-03-30

### Added

- Global hotkey `Cmd+Shift+C` to convert clipboard to rich text
- ANSI escape code stripping (CSI, OSC, SGR, 8/24-bit color)
- Claude Code UI marker removal (⏺▶◼●)
- Markdown → HTML conversion via cmark-gfm (GFM extensions)
- Inline CSS styling for code blocks, tables, headings, blockquotes
- Box-drawing Unicode table → Markdown table conversion
- NSPasteboard multi-format write (HTML + plain text)
- macOS menu bar app with status icon
- Toast notifications for conversion feedback
- Support for Notion, Slack, Google Docs, Apple Mail

[Unreleased]: https://github.com/freedom07/ccpaste/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/freedom07/ccpaste/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/freedom07/ccpaste/releases/tag/v1.0.0
