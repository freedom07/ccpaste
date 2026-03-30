import Foundation

enum TerminalNormalizer {

    // MARK: - Public

    static func normalize(_ text: String) -> String {
        var result = text
        result = stripANSI(result)
        result = removeClaudeMarkers(result)
        result = convertSimpleBoxTables(result)
        result = normalizeIndentation(result)
        return result
    }

    // MARK: - ANSI Escape Codes

    /// Strip all ANSI escape sequences (CSI, SGR, OSC, 8/24-bit color, etc.)
    private static func stripANSI(_ text: String) -> String {
        // Covers CSI sequences, OSC sequences, and other escape sequences
        let patterns = [
            "\\x1B\\[[0-9;]*[A-Za-z]",           // CSI: ESC [ ... letter
            "\\x1B\\].*?(?:\\x07|\\x1B\\\\)",     // OSC: ESC ] ... BEL or ST
            "\\x1B[()][AB012]",                    // Character set selection
            "\\x1B[>=NOMDEHcn]",                   // Simple escape sequences
            "\\x1B\\[\\?[0-9;]*[hl]",             // DEC private mode
            "\\x9B[0-9;]*[A-Za-z]",               // 8-bit CSI
        ]
        let combined = patterns.joined(separator: "|")

        guard let regex = try? NSRegularExpression(pattern: combined) else {
            return text
        }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
    }

    // MARK: - Claude UI Markers

    /// Remove Claude Code UI markers: ⏺ ▶ ◼ ● and leading whitespace on those lines
    private static func removeClaudeMarkers(_ text: String) -> String {
        let markers: Set<Character> = [
            "\u{23FA}",  // ⏺
            "\u{25B6}",  // ▶
            "\u{25FC}",  // ◼
            "\u{25CF}",  // ●
        ]

        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let cleaned = lines.map { line -> Substring in
            let trimmed = line.drop(while: { $0.isWhitespace })
            if let first = trimmed.first, markers.contains(first) {
                // Remove the marker and any following whitespace
                let afterMarker = trimmed.dropFirst().drop(while: { $0.isWhitespace })
                return afterMarker
            }
            return line
        }
        return cleaned.joined(separator: "\n")
    }

    // MARK: - Box-Drawing Tables

    /// Convert simple box-drawing tables to Markdown tables.
    /// Only converts tables with consistent column structure.
    /// Complex/nested tables are left as-is.
    private static func convertSimpleBoxTables(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var tableLines: [String] = []
        var inTable = false

        for line in lines {
            let isBoxLine = line.contains("│") || line.contains("┃") ||
                            line.contains("├") || line.contains("┤") ||
                            line.contains("┌") || line.contains("┐") ||
                            line.contains("└") || line.contains("┘") ||
                            line.contains("─") || line.contains("═") ||
                            line.contains("╔") || line.contains("╗") ||
                            line.contains("╚") || line.contains("╝") ||
                            line.contains("╟") || line.contains("╢")

            if isBoxLine {
                inTable = true
                tableLines.append(line)
            } else {
                if inTable {
                    if let mdTable = tryConvertTable(tableLines) {
                        result.append(mdTable)
                    } else {
                        result.append(contentsOf: tableLines)
                    }
                    tableLines.removeAll()
                    inTable = false
                }
                result.append(line)
            }
        }

        // Handle table at end of text
        if inTable {
            if let mdTable = tryConvertTable(tableLines) {
                result.append(mdTable)
            } else {
                result.append(contentsOf: tableLines)
            }
        }

        return result.joined(separator: "\n")
    }

    /// Try to convert box-drawing lines to a Markdown table.
    /// Returns nil if the table is too complex to convert.
    private static func tryConvertTable(_ lines: [String]) -> String? {
        let separatorChars: Set<Character> = ["─", "━", "═", "┌", "┐", "└", "┘", "├", "┤", "┬", "┴", "┼", "╔", "╗", "╚", "╝", "╟", "╢", "╠", "╣", "╤", "╧", "╪"]

        // Extract data rows (lines containing │ or ┃ with actual content)
        var dataRows: [[String]] = []
        for line in lines {
            // Skip separator lines
            let stripped = line.filter { !$0.isWhitespace && !separatorChars.contains($0) && $0 != "│" && $0 != "┃" && $0 != "║" }
            if stripped.isEmpty { continue }

            // Split by column separator
            let cells = line.split(separator: "│").map { $0.trimmingCharacters(in: .whitespaces) }
            let filteredCells = cells.filter { !$0.isEmpty }
            if filteredCells.isEmpty { continue }
            dataRows.append(filteredCells)
        }

        guard dataRows.count >= 2 else { return nil }

        // Verify consistent column count
        let colCount = dataRows[0].count
        guard dataRows.allSatisfy({ $0.count == colCount }) else { return nil }

        // Build markdown table
        var mdLines: [String] = []
        let header = "| " + dataRows[0].joined(separator: " | ") + " |"
        mdLines.append(header)
        let separator = "| " + Array(repeating: "---", count: colCount).joined(separator: " | ") + " |"
        mdLines.append(separator)
        for row in dataRows.dropFirst() {
            mdLines.append("| " + row.joined(separator: " | ") + " |")
        }

        return mdLines.joined(separator: "\n")
    }

    // MARK: - Indentation

    /// Normalize mixed indentation to consistent spaces
    private static func normalizeIndentation(_ text: String) -> String {
        // Replace tabs with 4 spaces for consistency
        return text.replacingOccurrences(of: "\t", with: "    ")
    }
}
