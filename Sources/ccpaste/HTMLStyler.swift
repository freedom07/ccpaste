import Foundation

enum HTMLStyler {

    /// Apply inline CSS styles to HTML elements for rich-text clipboard compatibility.
    /// Uses inline `style` attributes (not `<style>` blocks) for maximum paste compatibility.
    static func applyStyles(_ html: String) -> String {
        var result = html

        // Code blocks: dark background, monospace
        result = result.replacingOccurrences(
            of: "<pre>",
            with: "<pre style=\"background:#1e1e1e;color:#d4d4d4;padding:12px;border-radius:6px;font-family:'SF Mono',Menlo,Monaco,Consolas,monospace;font-size:13px;line-height:1.4;overflow-x:auto;\">"
        )

        // Inline code: light grey background
        // Avoid matching <code> inside <pre><code>
        result = replaceInlineCode(result)

        // Blockquotes
        result = result.replacingOccurrences(
            of: "<blockquote>",
            with: "<blockquote style=\"border-left:3px solid #ccc;padding-left:12px;margin-left:0;color:#555;\">"
        )

        // Tables
        result = result.replacingOccurrences(
            of: "<table>",
            with: "<table style=\"border-collapse:collapse;border:1px solid #ddd;\">"
        )
        result = result.replacingOccurrences(
            of: "<th>",
            with: "<th style=\"border:1px solid #ddd;padding:6px 12px;background:#f5f5f5;font-weight:bold;text-align:left;\">"
        )
        result = result.replacingOccurrences(
            of: "<td>",
            with: "<td style=\"border:1px solid #ddd;padding:6px 12px;\">"
        )

        // Headings
        result = result.replacingOccurrences(
            of: "<h1>",
            with: "<h1 style=\"font-weight:bold;font-size:1.6em;margin:0.6em 0 0.3em;\">"
        )
        result = result.replacingOccurrences(
            of: "<h2>",
            with: "<h2 style=\"font-weight:bold;font-size:1.3em;margin:0.5em 0 0.3em;\">"
        )
        result = result.replacingOccurrences(
            of: "<h3>",
            with: "<h3 style=\"font-weight:bold;font-size:1.1em;margin:0.4em 0 0.2em;\">"
        )

        return result
    }

    /// Replace inline <code> tags (not inside <pre>) with styled versions.
    private static func replaceInlineCode(_ html: String) -> String {
        // Split by <pre>...</pre> blocks and only style <code> outside them
        guard let prePattern = try? NSRegularExpression(pattern: "<pre[^>]*>.*?</pre>", options: .dotMatchesLineSeparators) else {
            return html
        }

        let nsHTML = html as NSString
        let matches = prePattern.matches(in: html, range: NSRange(location: 0, length: nsHTML.length))

        var result = ""
        var lastEnd = 0

        for match in matches {
            // Process text before this <pre> block
            let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
            let beforeText = nsHTML.substring(with: beforeRange)
            result += styleInlineCodeTags(beforeText)

            // Keep <pre> block as-is
            result += nsHTML.substring(with: match.range)
            lastEnd = match.range.location + match.range.length
        }

        // Process remaining text after last <pre> block
        let remainingRange = NSRange(location: lastEnd, length: nsHTML.length - lastEnd)
        let remaining = nsHTML.substring(with: remainingRange)
        result += styleInlineCodeTags(remaining)

        return result
    }

    private static func styleInlineCodeTags(_ text: String) -> String {
        text.replacingOccurrences(
            of: "<code>",
            with: "<code style=\"background:#f5f5f5;padding:2px 4px;border-radius:3px;font-family:'SF Mono',Menlo,Monaco,Consolas,monospace;font-size:0.9em;\">"
        )
    }
}
