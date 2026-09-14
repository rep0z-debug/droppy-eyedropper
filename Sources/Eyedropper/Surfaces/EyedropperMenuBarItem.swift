import DroppyKit
import SwiftUI

extension EyedropperDroplet: MenuBarExtraProviding {
    public func makeMenuBarExtra() -> MenuBarExtraDescriptor? {
        guard showsMenuBarItem else { return nil }
        return MenuBarExtraDescriptor(title: "Eyedropper", systemImage: "eyedropper") { [weak self] in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(EyedropperMenu(droplet: self))
        }
    }
}

private struct EyedropperMenu: View {
    @ObservedObject var droplet: EyedropperDroplet

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            MenuRow(icon: "eyedropper", title: "Pick a color") {
                droplet.pickColor()
            }
            if !droplet.recentColors.isEmpty {
                Divider()
                    .padding(.horizontal, DroppySpacing.md)
                    .padding(.vertical, DroppySpacing.xs)
                ForEach(droplet.recentColors.prefix(8)) { color in
                    MenuRow(swatch: color, title: color.text(in: droplet.notation)) {
                        droplet.copy(color)
                    }
                }
            }
        }
        .padding(.vertical, DroppySpacing.xs)
        .frame(minWidth: 240, alignment: .leading)
    }
}

private struct MenuRow: View {
    var icon: String?
    var swatch: SampledColor?
    let title: String
    let action: () -> Void

    @State private var isHighlighted = false

    init(icon: String, title: String, action: @escaping () -> Void) {
        self.icon = icon
        self.swatch = nil
        self.title = title
        self.action = action
    }

    init(swatch: SampledColor, title: String, action: @escaping () -> Void) {
        self.icon = nil
        self.swatch = swatch
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DroppySpacing.smd) {
                leading
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: swatch == nil ? .default : .rounded))
                    .monospacedDigit()
                Spacer(minLength: DroppySpacing.md)
            }
            .padding(.horizontal, DroppySpacing.md)
            .frame(height: 30)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DroppyRadius.small, style: .continuous)
                    .fill(AdaptiveColors.primaryTextAuto.opacity(isHighlighted ? 0.1 : 0))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DroppySpacing.xs)
        .onHover { isHighlighted = $0 }
    }

    @ViewBuilder
    private var leading: some View {
        if let icon {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 18, alignment: .center)
        } else if let swatch {
            ColorTile(color: swatch, size: 14, cornerRadius: DroppyRadius.xs)
                .frame(width: 18, alignment: .center)
        }
    }
}
