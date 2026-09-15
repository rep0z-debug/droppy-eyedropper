import DroppyKit
import SwiftUI

extension EyedropperDroplet: HUDPresenting {}

struct NotchReadout: View {
    let color: SampledColor
    let notation: ColorNotation

    private var dotSize: CGFloat { DroppyLiveActivityMetrics.iconSize + 3 }

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(color.swatch)
                .frame(width: dotSize, height: dotSize)
                .overlay(
                    Circle().strokeBorder(AdaptiveColors.notchSurfacePrimaryText.opacity(0.18), lineWidth: 1)
                )
            Spacer(minLength: 0)
            Text(color.text(in: notation))
                .font(.system(size: DroppyLiveActivityMetrics.labelFontSize, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NotchReadoutCard: View {
    let color: SampledColor
    let notation: ColorNotation

    var body: some View {
        HStack(spacing: DroppySpacing.md) {
            ColorTile(color: color, size: 34, cornerRadius: DroppyRadius.small)
            Text(color.text(in: notation))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
