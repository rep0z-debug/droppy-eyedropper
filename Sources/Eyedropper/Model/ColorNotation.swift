import Foundation

public enum ColorNotation: String, CaseIterable, Codable, Sendable, Identifiable {
    case hex
    case rgb
    case hsl

    public var id: String { rawValue }

    var shortName: String {
        switch self {
        case .hex: return "Hex"
        case .rgb: return "RGB"
        case .hsl: return "HSL"
        }
    }

    var glyph: String {
        switch self {
        case .hex: return "number"
        case .rgb: return "circle.grid.3x3.fill"
        case .hsl: return "dial.medium"
        }
    }
}
