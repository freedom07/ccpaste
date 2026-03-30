import Foundation
import libcmark_gfm

enum MarkdownConverter {

    /// Convert Markdown text to HTML using cmark-gfm with GFM extensions.
    /// Falls back to wrapping in `<pre>` tags if parsing fails.
    static func toHTML(_ markdown: String) -> String {
        // Register GFM extensions (table, strikethrough, autolink, tagfilter)
        cmark_gfm_core_extensions_ensure_registered()

        let options = CMARK_OPT_UNSAFE | CMARK_OPT_SMART

        // Create parser and attach GFM extensions
        guard let parser = cmark_parser_new(Int32(options)) else {
            return fallbackHTML(markdown)
        }
        defer { cmark_parser_free(parser) }

        let extensionNames = ["table", "strikethrough", "autolink", "tagfilter"]
        for name in extensionNames {
            if let ext = cmark_find_syntax_extension(name) {
                cmark_parser_attach_syntax_extension(parser, ext)
            }
        }

        // Feed text and finish parsing
        let data = markdown.utf8CString
        data.withUnsafeBufferPointer { buffer in
            // buffer includes null terminator, subtract 1 for actual length
            if let baseAddress = buffer.baseAddress {
                cmark_parser_feed(parser, baseAddress, data.count - 1)
            }
        }

        guard let document = cmark_parser_finish(parser) else {
            return fallbackHTML(markdown)
        }
        defer { cmark_node_free(document) }

        // Collect attached extensions for rendering
        var extensions: UnsafeMutablePointer<cmark_llist>? = nil
        for name in extensionNames {
            if let ext = cmark_find_syntax_extension(name) {
                extensions = cmark_llist_append(cmark_get_default_mem_allocator(), extensions, ext)
            }
        }
        defer {
            if let exts = extensions {
                cmark_llist_free(cmark_get_default_mem_allocator(), exts)
            }
        }

        guard let htmlCString = cmark_render_html(document, Int32(options), extensions) else {
            return fallbackHTML(markdown)
        }
        defer { free(htmlCString) }

        return String(cString: htmlCString)
    }

    /// Fallback: wrap plain text in <pre> tags
    private static func fallbackHTML(_ text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        return "<pre>\(escaped)</pre>"
    }
}
