import SwiftUI

public struct SampledColor: Codable, Hashable, Identifiable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double
    public let pickedAt: Date

    public var id: String { "\(hexString)-\(pickedAt.timeIntervalSinceReferenceDate)" }

    public var swatch: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    var hexString: String {
        "#" + ColorMath.hexComponent(red) + ColorMath.hexComponent(green) + ColorMath.hexComponent(blue)
    }

    var rgbString: String {
        "rgb(\(ColorMath.byteValue(red)), \(ColorMath.byteValue(green)), \(ColorMath.byteValue(blue)))"
    }

    var hslString: String {
        let parts = ColorMath.hueSaturationLightness(red: red, green: green, blue: blue)
        return "hsl(\(parts.hue), \(parts.saturation)%, \(parts.lightness)%)"
    }

    var hsbString: String {
        let parts = ColorMath.hueSaturationBrightness(red: red, green: green, blue: blue)
        return "hsb(\(parts.hue), \(parts.saturation)%, \(parts.brightness)%)"
    }

    var swiftString: String {
        func component(_ value: Double) -> String { String(format: "%.2f", value) }
        return "Color(red: \(component(red)), green: \(component(green)), blue: \(component(blue)))"
    }

    func text(in notation: ColorNotation) -> String {
        switch notation {
        case .hex: return hexString
        case .rgb: return rgbString
        case .hsl: return hslString
        case .hsb: return hsbString
        case .swiftUI: return swiftString
        }
    }

    func looksLike(_ other: SampledColor) -> Bool {
        ColorMath.byteValue(red) == ColorMath.byteValue(other.red)
            && ColorMath.byteValue(green) == ColorMath.byteValue(other.green)
            && ColorMath.byteValue(blue) == ColorMath.byteValue(other.blue)
    }
}
