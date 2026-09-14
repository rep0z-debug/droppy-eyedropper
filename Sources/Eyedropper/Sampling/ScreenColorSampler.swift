import AppKit

enum ScreenColorSampler {
    @MainActor
    static func sample() async -> SampledColor? {
        await withCheckedContinuation { continuation in
            NSColorSampler().show { picked in
                guard let picked, let converted = picked.usingColorSpace(.sRGB) else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(
                    returning: SampledColor(
                        red: Double(converted.redComponent),
                        green: Double(converted.greenComponent),
                        blue: Double(converted.blueComponent),
                        opacity: Double(converted.alphaComponent),
                        pickedAt: Date()
                    )
                )
            }
        }
    }
}
