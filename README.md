# Clipboard Manager (macOS)

Standalone SwiftUI macOS app that is menu bar-driven and also has a full window.

## Features

- Dock icon and menu bar icon together.
- Captures clipboard changes (text and images).
- Persists history to disk.
- Stores up to the most recent 100 entries.
- Restores any history item back to the clipboard.
- Includes a launch-at-login toggle in Settings.

## Project Layout

- `Sources/clipboard/ClipboardApp.swift`: app entry with `WindowGroup` + `MenuBarExtra`.
- `Sources/clipboard/ClipboardWatcher.swift`: monitors `NSPasteboard`.
- `Sources/clipboard/HistoryStore.swift`: persistence, dedupe, pruning.
- `Sources/clipboard/HistoryWindowView.swift`: full history window.
- `Sources/clipboard/MenuBarView.swift`: menu bar popover UI.

## Build and Test

Use `--disable-sandbox` in this environment:

```bash
HOME=/Users/sagarvarma/Desktop/clipboard CLANG_MODULE_CACHE_PATH=/Users/sagarvarma/Desktop/clipboard/.build/ModuleCache swift build --disable-sandbox
HOME=/Users/sagarvarma/Desktop/clipboard CLANG_MODULE_CACHE_PATH=/Users/sagarvarma/Desktop/clipboard/.build/ModuleCache swift test --disable-sandbox
```

## Run

```bash
HOME=/Users/sagarvarma/Desktop/clipboard CLANG_MODULE_CACHE_PATH=/Users/sagarvarma/Desktop/clipboard/.build/ModuleCache swift run --disable-sandbox
```

Clipboard history is stored under your Application Support directory in a `ClipboardManager`-style folder (bundle-id based when available).

## Launch At Login

The toggle is in app Settings. macOS may require a signed app bundle in `/Applications` for login-item registration to succeed.
