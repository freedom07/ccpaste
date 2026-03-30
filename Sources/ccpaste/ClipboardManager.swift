import AppKit

enum ClipboardManager {

    /// Read plain text from the system clipboard.
    /// Returns nil if clipboard is empty or contains no text.
    static func readPlainText() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }

    /// Write rich text (HTML + plain text) to the system clipboard.
    /// Sets both HTML and plain text types so apps can choose the best format.
    static func writeRichText(html: String, plainText: String) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        guard let htmlData = html.data(using: .utf8) else {
            return false
        }

        pasteboard.setData(htmlData, forType: .html)
        pasteboard.setString(plainText, forType: .string)

        return true
    }
}
