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
            if let latest = droplet.recentColors.first {
                filled(latest: latest)
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
            Button {
                droplet.pickColor()
            } label: {
                Image(systemName: "eyedropper.halffull")
            }
            .buttonStyle(DroppyCircleButtonStyle(size: 20))
            .help("Pick a color")
            .accessibilityLabel("Pick a color")
        }
        .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
    }

    @ViewBuilder
    private func filled(latest: SampledColor) -> some View {
        if context.isCompact {
            hero(latest: latest, tileSize: 40)
        } else {
            hero(latest: latest, tileSize: 46)
            recentStrip
            notationRow
        }
    }

    private func hero(latest: SampledColor, tileSize: CGFloat) -> some View {
        Button {
            droplet.copy(latest)
        } label: {
            HStack(spacing: DroppySpacing.smd) {
                ColorTile(color: latest, size: tileSize, cornerRadius: DroppyRadius.medium)
                VStack(alignment: .leading, spacing: 2) {
                    Text(latest.text(in: droplet.notation))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
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

    private var recentStrip: some View {
        HStack(spacing: DroppySpacing.xs) {
            ForEach(droplet.recentColors.dropFirst().prefix(9)) { color in
                Button {
                    droplet.copy(color)
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
        VStack(alignment: .leading, spacing: DroppySpacing.sm) {
            Text(context.isCompact ? "No colors yet" : "Pick a color from anywhere on screen.")
                .font(.system(size: context.isCompact ? 12 : 13))
                .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
            Button {
                droplet.pickColor()
            } label: {
                Label("Pick a color", systemImage: "eyedropper")
            }
            .buttonStyle(DroppyAccentButtonStyle(size: .small))
        }
    }
}
