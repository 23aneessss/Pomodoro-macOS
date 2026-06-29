import SwiftUI

/// A tiny hand-built bitmap font so timer text renders as true, crisp pixel art
/// at any size — no font file to bundle, no licensing, always sharp.
/// Covers the glyphs the timer and labels actually use: 0-9, A-Z, ":", " ".
enum PixelFont {
    static let rows = 7

    /// Each glyph is 7 rows tall. "1" = filled pixel. Widths vary per glyph.
    static let glyphs: [Character: [String]] = [
        "0": ["11111", "10001", "10011", "10101", "11001", "10001", "11111"],
        "1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
        "2": ["11111", "00001", "00001", "11111", "10000", "10000", "11111"],
        "3": ["11111", "00001", "00001", "01111", "00001", "00001", "11111"],
        "4": ["10001", "10001", "10001", "11111", "00001", "00001", "00001"],
        "5": ["11111", "10000", "10000", "11111", "00001", "00001", "11111"],
        "6": ["11111", "10000", "10000", "11111", "10001", "10001", "11111"],
        "7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
        "8": ["11111", "10001", "10001", "11111", "10001", "10001", "11111"],
        "9": ["11111", "10001", "10001", "11111", "00001", "00001", "11111"],
        ":": ["00", "11", "11", "00", "11", "11", "00"],
        " ": ["000", "000", "000", "000", "000", "000", "000"],
        "A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
        "B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
        "C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
        "D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
        "E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
        "F": ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
        "G": ["01111", "10000", "10000", "10111", "10001", "10001", "01111"],
        "H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
        "I": ["111", "010", "010", "010", "010", "010", "111"],
        "K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
        "M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
        "N": ["10001", "11001", "10101", "10101", "10101", "10011", "10001"],
        "O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
        "P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
        "R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
        "S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
        "T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
        "U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
        "Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"]
    ]

    static func width(of ch: Character) -> Int {
        glyphs[ch]?.first?.count ?? 0
    }
}

/// Renders a string in `PixelFont` as solid pixel blocks via a single Canvas,
/// so it stays perfectly crisp and updates cheaply once per second.
struct PixelTextView: View {
    let text: String
    var cell: CGFloat = 4
    var color: Color
    var shadow: Color? = nil
    /// Empty cells between glyphs.
    var letterSpacing: Int = 1

    private var glyphs: [(grid: [String], width: Int)] {
        text.uppercased().compactMap { ch in
            guard let grid = PixelFont.glyphs[ch] else { return nil }
            return (grid, PixelFont.width(of: ch))
        }
    }

    private var columns: Int {
        let items = glyphs
        guard !items.isEmpty else { return 0 }
        let glyphWidth = items.reduce(0) { $0 + $1.width }
        return glyphWidth + (items.count - 1) * letterSpacing
    }

    private var contentWidth: CGFloat { CGFloat(columns) * cell }
    private var contentHeight: CGFloat { CGFloat(PixelFont.rows) * cell }
    private var shadowOffset: CGFloat { shadow == nil ? 0 : cell }

    var body: some View {
        Canvas { context, _ in
            if let shadow {
                draw(in: context, color: shadow, dx: shadowOffset, dy: shadowOffset)
            }
            draw(in: context, color: color, dx: 0, dy: 0)
        }
        .frame(width: contentWidth + shadowOffset, height: contentHeight + shadowOffset)
        .accessibilityHidden(true)
    }

    private func draw(in context: GraphicsContext, color: Color, dx: CGFloat, dy: CGFloat) {
        var columnOffset = 0
        for glyph in glyphs {
            for (rowIndex, row) in glyph.grid.enumerated() {
                for (colIndex, pixel) in row.enumerated() where pixel == "1" {
                    let rect = CGRect(
                        x: CGFloat(columnOffset + colIndex) * cell + dx,
                        y: CGFloat(rowIndex) * cell + dy,
                        width: cell,
                        height: cell
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
            columnOffset += glyph.width + letterSpacing
        }
    }
}
