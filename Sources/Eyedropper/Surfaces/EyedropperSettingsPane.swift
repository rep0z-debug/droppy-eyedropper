import DroppyKit
import SwiftUI

extension EyedropperDroplet: SettingsPaneProviding {
    public func makeSettingsPane(context: SettingsPaneContext) -> AnyView {
        AnyView(EyedropperSettings(droplet: self))
    }

    public var settingsSearchEntries: [SettingsSearchEntry] {
        [
            SettingsSearchEntry(
                title: "Eyedropper",
                keywords: ["color", "hex", "rgb", "hsl", "palette", "eyedropper", "shortcut", "menu bar"]
            )
        ]
    }
}

private struct EyedropperSettings: View {
    @ObservedObject var droplet: EyedropperDroplet

    private var automaticCopy: Binding<Bool> {
        Binding(
            get: { droplet.copiesAutomatically },
            set: { droplet.setCopiesAutomatically($0) }
        )
    }

    private var menuBarVisible: Binding<Bool> {
        Binding(
            get: { droplet.showsMenuBarItem },
            set: { droplet.setShowsMenuBarItem($0) }
        )
    }

    private var notchVisible: Binding<Bool> {
        Binding(
            get: { droplet.showsInNotch },
            set: { droplet.setShowsInNotch($0) }
        )
    }

    private var notchSeconds: Binding<Double> {
        Binding(
            get: { droplet.notchSeconds },
            set: { droplet.setNotchSeconds($0) }
        )
    }

    private var durationLabel: String {
        let seconds = droplet.notchSeconds
        return seconds == seconds.rounded() ? "\(Int(seconds)) s" : String(format: "%.1f s", seconds)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.lg) {
            DropletSettingsCard {
                settingsUnifiedPickerRow(
                    title: "Default format",
                    subtitle: "The value Eyedropper copies when you pick a color.",
                    options: ColorNotation.allCases,
                    groupPosition: .top,
                    isSelected: { $0 == droplet.notation },
                    action: { droplet.chooseNotation($0) }
                ) { option, isSelected, isEnabled in
                    settingsUnifiedSegmentLabel(
                        icon: option.glyph,
                        title: option.shortName,
                        isSelected: isSelected,
                        isEnabled: isEnabled
                    )
                }
                DropletSettingsDivider()
                DropletToggleRow(
                    title: "Copy automatically",
                    subtitle: "Put the value on the clipboard when you select a color.",
                    isOn: automaticCopy
                )
                DropletSettingsDivider()
                DropletToggleRow(
                    title: "Show in menu bar",
                    subtitle: "Get Eyedropper at the top of your Mac.",
                    isOn: menuBarVisible
                )
            }

            DropletSettingsCard {
                DropletToggleRow(
                    title: "Show in the notch",
                    subtitle: "Flash the color above the notch when you pick or copy one.",
                    isOn: notchVisible
                )
                if droplet.showsInNotch {
                    DropletSettingsDivider()
                    DropletSliderRow(
                        title: "Show for",
                        value: durationLabel,
                        binding: notchSeconds,
                        range: EyedropperDroplet.notchSecondsRange,
                        step: 0.5
                    )
                }
            }

            DropletSettingsCard {
                DropletControlRow(
                    title: "Pick a color",
                    infoTip: "Press the shortcut anywhere to start picking. Click it to record your own."
                ) {
                    HStack(spacing: DroppySpacing.sm) {
                        if droplet.pickShortcut != EyedropperDroplet.defaultPickShortcut {
                            Button("Reset") { droplet.resetShortcut() }
                                .buttonStyle(DroppyQuietButtonStyle(size: .small))
                        }
                        ShortcutField(shortcut: droplet.pickShortcut) { droplet.setShortcut($0) }
                        Button {
                            droplet.pickColor()
                        } label: {
                            Label("Pick", systemImage: "eyedropper")
                        }
                        .buttonStyle(DroppyQuietButtonStyle(size: .small))
                    }
                }
            }

            DropletSettingsCard {
                DropletStackedRow(
                    title: "Recent colors",
                    infoTip: "Pick colors from anywhere on the screen and the last few get saved here. Click one to copy it again."
                ) {
                    palette
                }
                DropletSettingsDivider()
                DropletControlRow(title: "Palette") {
                    HStack(spacing: DroppySpacing.sm) {
                        Button("Copy all") {
                            droplet.copyPalette()
                        }
                        .buttonStyle(DroppyQuietButtonStyle(size: .small))
                        .disabled(droplet.recentColors.isEmpty)
                        Button("Clear") {
                            droplet.clearPalette()
                        }
                        .buttonStyle(DroppyQuietButtonStyle(size: .small, destructive: true))
                        .disabled(droplet.recentColors.isEmpty)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var palette: some View {
        if droplet.recentColors.isEmpty {
            Text("Nothing picked yet.")
                .font(.callout)
                .foregroundStyle(.secondary)
        } else {
            HStack(spacing: DroppySpacing.xs) {
                ForEach(droplet.recentColors.prefix(12)) { color in
                    Button {
                        droplet.copy(color)
                    } label: {
                        ColorTile(color: color, size: 24, cornerRadius: DroppyRadius.small)
                    }
                    .buttonStyle(.plain)
                    .help(color.text(in: droplet.notation))
                }
                Spacer(minLength: 0)
            }
        }
    }
}
