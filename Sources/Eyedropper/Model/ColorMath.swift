import Foundation

enum ColorMath {
    static func byteValue(_ value: Double) -> Int {
        min(255, max(0, Int((value * 255).rounded())))
    }

    static func hexComponent(_ value: Double) -> String {
        String(format: "%02X", byteValue(value))
    }

    static func hueSaturationLightness(
        red: Double,
        green: Double,
        blue: Double
    ) -> (hue: Int, saturation: Int, lightness: Int) {
        let highest = max(red, green, blue)
        let lowest = min(red, green, blue)
        let spread = highest - lowest
        let lightness = (highest + lowest) / 2

        guard spread > 0 else {
            return (hue: 0, saturation: 0, lightness: Int((lightness * 100).rounded()))
        }

        let saturation = spread / (1 - abs(2 * lightness - 1))
        var hue: Double
        if highest == red {
            hue = ((green - blue) / spread).truncatingRemainder(dividingBy: 6)
        } else if highest == green {
            hue = (blue - red) / spread + 2
        } else {
            hue = (red - green) / spread + 4
        }
        hue *= 60
        if hue < 0 { hue += 360 }

        return (
            hue: Int(hue.rounded()),
            saturation: Int((saturation * 100).rounded()),
            lightness: Int((lightness * 100).rounded())
        )
    }

    static func hueSaturationBrightness(
        red: Double,
        green: Double,
        blue: Double
    ) -> (hue: Int, saturation: Int, brightness: Int) {
        let highest = max(red, green, blue)
        let lowest = min(red, green, blue)
        let spread = highest - lowest
        let saturation = highest == 0 ? 0 : spread / highest

        var hue = 0.0
        if spread != 0 {
            if highest == red {
                hue = ((green - blue) / spread).truncatingRemainder(dividingBy: 6)
            } else if highest == green {
                hue = (blue - red) / spread + 2
            } else {
                hue = (red - green) / spread + 4
            }
            hue *= 60
            if hue < 0 { hue += 360 }
        }

        return (
            hue: Int(hue.rounded()),
            saturation: Int((saturation * 100).rounded()),
            brightness: Int((highest * 100).rounded())
        )
    }

    static func relativeLuminance(red: Double, green: Double, blue: Double) -> Double {
        func straighten(_ channel: Double) -> Double {
            channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * straighten(red) + 0.7152 * straighten(green) + 0.0722 * straighten(blue)
    }
}
