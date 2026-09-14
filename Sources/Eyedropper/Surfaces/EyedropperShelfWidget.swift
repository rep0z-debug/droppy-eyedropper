import DroppyKit
import SwiftUI

extension EyedropperDroplet: ShelfWidgetProviding {
    public var widgetDescriptors: [ShelfWidgetDescriptor] {
        [
            ShelfWidgetDescriptor(
                id: "palette",
                title: "Eyedropper",
                systemImage: "eyedropper",
                layoutTraits: ShelfWidgetLayoutTraits(
                    preferredSoloWidth: 420,
                    preferredPairedWidth: 210,
                    contentHeight: .fixed(150)
                ),
                searchKeywords: ["color", "eyedropper", "hex", "rgb", "palette"]
            )
        ]
    }

    public func makeWidgetView(_ id: ShelfWidgetID, context: ShelfWidgetContext) -> AnyView {
        AnyView(PaletteWidget(droplet: self, context: context))
    }

    public func makeWidgetSettingsPopover(_ id: ShelfWidgetID) -> AnyView? { nil }
}

private struct PaletteWidget: View {
    @ObservedObject var droplet: EyedropperDroplet
    let context: ShelfWidgetContext

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.sm) {
            header
            if let current = droplet.displayedColor {
                filled(current: current)
            } else {
                placeholder
            }
            Spacer(minLength: 0)
        }
        .padding(context.contentInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        HStack(spacing: DroppySpacing.xsm) {
            Image(systemName: "eyedropper")
                .font(.system(size: 12, weight: .medium))
            Text("Eyedropper")
                .font(.system(size: 12, weight: .semibold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
    }

    @ViewBuilder
    private func filled(current: SampledColor) -> some View {
        if context.isCompact {
            hero(current: current, tileSize: 40)
        } else {
            hero(current: current, tileSize: 46)
            recentStrip(current: current)
            notationRow
        }
    }

    private func hero(current: SampledColor, tileSize: CGFloat) -> some View {
        Button {
            droplet.copy(current)
        } label: {
            HStack(spacing: DroppySpacing.smd) {
                ColorTile(color: current, size: tileSize, cornerRadius: DroppyRadius.medium)
                VStack(alignment: .leading, spacing: 2) {
                    Text(current.text(in: droplet.notation))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("Tap to copy")
                        .font(.system(size: 10))
                        .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func recentStrip(current: SampledColor) -> some View {
        HStack(spacing: DroppySpacing.xs) {
            ForEach(droplet.recentColors.filter { $0.id != current.id }.prefix(9)) { color in
                Button {
                    droplet.select(color)
                } label: {
                    ColorTile(color: color, size: 22, cornerRadius: DroppyRadius.small)
                }
                .buttonStyle(.plain)
                .help(color.text(in: droplet.notation))
            }
            Spacer(minLength: 0)
        }
    }

    private var notationRow: some View {
        HStack(spacing: DroppySpacing.xs) {
            ForEach(ColorNotation.allCases) { option in
                notationButton(option)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func notationButton(_ option: ColorNotation) -> some View {
        if option == droplet.notation {
            Button(option.shortName) { droplet.chooseNotation(option) }
                .buttonStyle(DroppyAccentButtonStyle(size: .small))
        } else {
            Button(option.shortName) { droplet.chooseNotation(option) }
                .buttonStyle(DroppyQuietButtonStyle(size: .small))
        }
    }

    private var placeholder: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.xsm) {
            Text("No colors yet")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
            Text(pickHint)
                .font(.system(size: 11))
                .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
        }
    }

    private var pickHint: String {
        if let shortcut = droplet.pickShortcut {
            return "Press \(ShortcutText.label(shortcut)) to pick a color."
        }
        return "Set a shortcut in Settings to start picking."
    }
}
