# Contributing to ccpaste

Thank you for your interest in contributing to ccpaste! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ccpaste.git
   cd ccpaste
   ```
3. Build and run:
   ```bash
   bash build.sh
   open .build/release/ccpaste.app
   ```

## Development

### Prerequisites

- macOS 13.0+
- Swift 5.9+
- Xcode Command Line Tools (`xcode-select --install`)

### Project Structure

```
Sources/ccpaste/
├── main.swift              # App entry point
├── AppDelegate.swift       # Menu bar + hotkey + pipeline orchestration
├── TerminalNormalizer.swift # ANSI/marker stripping, box-drawing conversion
├── MarkdownConverter.swift  # cmark-gfm MD → HTML
├── HTMLStyler.swift         # Inline CSS injection
├── ClipboardManager.swift   # NSPasteboard read/write
└── ToastWindow.swift        # Floating toast UI
```

### Building

```bash
# Debug build
swift build

# Release build + app bundle
bash build.sh
```

## Submitting Changes

### Pull Requests

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature
   ```
2. Make your changes
3. Test manually with Notion, Slack, Google Docs, and Apple Mail
4. Commit with a clear message:
   ```bash
   git commit -m "Add: description of your change"
   ```
5. Push and open a Pull Request

### Commit Messages

Use clear, descriptive commit messages:

- `Add: new feature description`
- `Fix: bug description`
- `Update: what was changed and why`
- `Remove: what was removed and why`

### Code Style

- Follow existing Swift conventions in the codebase
- Keep functions focused and small
- No unnecessary abstractions — simple is better

## Reporting Issues

When reporting a bug, please include:

- macOS version
- Terminal app (iTerm2, Terminal.app, Warp, Ghostty, etc.)
- Steps to reproduce
- Expected vs actual behavior
- Sample text that triggers the issue (if applicable)

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
