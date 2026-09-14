import Foundation

public enum ColorNotation: String, CaseIterable, Codable, Sendable, Identifiable {
    case hex
    case rgb
    case hsl
    case hsb
    case swiftUI

    public var id: String { rawValue }

    var shortName: String {
        switch self {
        case .hex: return "Hex"
        case .rgb: return "RGB"
        case .hsl: return "HSL"
        case .hsb: return "HSB"
        case .swiftUI: return "Swift"
        }
    }

    var glyph: String {
        switch self {
        case .hex: return "number"
        case .rgb: return "circle.grid.3x3.fill"
        case .hsl: return "dial.medium"
        case .hsb: return "sun.max"
        case .swiftUI: return "swift"
        }
    }
}
