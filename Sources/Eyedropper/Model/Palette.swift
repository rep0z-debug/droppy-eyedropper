import Foundation

enum Palette {
    static let capacity = 12

    static func remembering(_ color: SampledColor, in colors: [SampledColor]) -> [SampledColor] {
        var kept = colors.filter { !$0.looksLike(color) }
        kept.insert(color, at: 0)
        if kept.count > capacity {
            kept.removeLast(kept.count - capacity)
        }
        return kept
    }
}
