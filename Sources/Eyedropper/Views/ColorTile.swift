import DroppyKit
import SwiftUI

struct ColorTile: View {
    let color: SampledColor
    var size: CGFloat
    var cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(color.swatch)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AdaptiveColors.notchSurfacePrimaryText.opacity(0.12), lineWidth: 1)
            )
    }
}
