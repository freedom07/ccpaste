import AppKit
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let toast = ToastWindow()
    private var hotKeyRef: EventHotKeyRef?

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        registerHotKey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterHotKey()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: "ccpaste")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "ccpaste — Rich Text Clipboard", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Convert Clipboard (⌘⇧C)", action: #selector(convertClipboard), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    // MARK: - Global Hot Key (Carbon)

    private func registerHotKey() {
        // Hot key ID
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x43435054)  // "CCPT"
        hotKeyID.id = 1

        // Install handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyCallback,
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            nil
        )

        guard status == noErr else {
            showAlert("Failed to install hot key handler (error: \(status))")
            return
        }

        // Register Cmd+Shift+C
        // Key code 8 = 'C', modifiers: cmdKey + shiftKey
        let modifiers = UInt32(cmdKey | shiftKey)
        let result = RegisterEventHotKey(
            UInt32(kVK_ANSI_C),
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if result != noErr {
            showAlert("Failed to register Cmd+Shift+C hot key (error: \(result)). Another app may be using this shortcut.")
        }
    }

    private func unregisterHotKey() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }

    private func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "ccpaste"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }

    // MARK: - Pipeline

    @objc func convertClipboard() {
        // 1. Read plain text from clipboard
        guard let text = ClipboardManager.readPlainText(), !text.isEmpty else {
            toast.show("No text in clipboard", isError: true)
            return
        }

        // 2. Normalize terminal output
        let normalized = TerminalNormalizer.normalize(text)

        // 3. Convert markdown to HTML
        let html = MarkdownConverter.toHTML(normalized)

        // 4. Apply inline CSS styles
        let styledHTML = HTMLStyler.applyStyles(html)

        // 5. Write rich text to clipboard
        let success = ClipboardManager.writeRichText(html: styledHTML, plainText: normalized)

        // 6. Show result
        if success {
            toast.show("Rich text ready")
        } else {
            toast.show("Failed to write clipboard", isError: true)
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

// MARK: - Carbon Hot Key Callback

private func hotKeyCallback(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData = userData else { return OSStatus(eventNotHandledErr) }
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()

    DispatchQueue.main.async {
        appDelegate.convertClipboard()
    }

    return noErr
}
