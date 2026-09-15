import AppKit
import Combine
import DroppyKit
import SwiftUI

@MainActor
public final class EyedropperDroplet: NSObject, ObservableObject, Droplet {
    public nonisolated static let id: DropletID = "eyedropper"

    static let defaultPickShortcut = DropletKeyboardShortcut(
        keyCode: 35,
        modifiers: NSEvent.ModifierFlags([.control, .option, .command]).rawValue
    )

    static let notchSecondsRange: ClosedRange<Double> = 1...6

    private static let pickShortcutID = "pick"

    @Published public private(set) var recentColors: [SampledColor] = []
    @Published public private(set) var activeColor: SampledColor?
    @Published public private(set) var notation: ColorNotation = .hex
    @Published public private(set) var copiesAutomatically = true
    @Published public private(set) var showsMenuBarItem = false
    @Published public private(set) var showsInNotch = true
    @Published public private(set) var notchSeconds: Double = 2.5
    @Published public private(set) var pickShortcut: DropletKeyboardShortcut?

    private var host: DropletHost?

    public func activate(host: DropletHost) throws {
        self.host = host
        restoreState(from: host)

        let saved = host.preferences.value(forKey: StorageKey.shortcut, as: DropletKeyboardShortcut.self)
        registerPickShortcut(host, suggesting: saved ?? Self.defaultPickShortcut)
        syncShortcut(with: host)

        let count = recentColors.count
        host.log.info("Eyedropper activated with \(count) saved color\(count == 1 ? "" : "s")")
    }

    public func deactivate() {
        host?.shortcuts.unregister(id: Self.pickShortcutID)
        host = nil
    }

    public func pickColor() {
        guard let host else { return }
        Task { [weak self] in
            guard let picked = await ScreenColorSampler.sample() else { return }
            self?.remember(picked, host: host)
        }
    }

    public func copy(_ color: SampledColor) {
        guard let host else { return }
        if host.workspace.copyToPasteboard(color.text(in: notation)) {
            host.feedback.play(.tick)
        }
        showReadout(for: color)
    }

    public var displayedColor: SampledColor? {
        if let activeColor, recentColors.contains(where: { $0.id == activeColor.id }) {
            return activeColor
        }
        return recentColors.first
    }

    public func select(_ color: SampledColor) {
        activeColor = color
        copy(color)
    }

    public func chooseNotation(_ value: ColorNotation) {
        notation = value
        host?.preferences.setValue(value.rawValue, forKey: StorageKey.notation)
    }

    public func setCopiesAutomatically(_ value: Bool) {
        copiesAutomatically = value
        host?.preferences.setValue(value, forKey: StorageKey.copiesAutomatically)
    }

    public func setShowsMenuBarItem(_ value: Bool) {
        showsMenuBarItem = value
        host?.preferences.setValue(value, forKey: StorageKey.showsMenuBarItem)
    }

    public func setShowsInNotch(_ value: Bool) {
        showsInNotch = value
        host?.preferences.setValue(value, forKey: StorageKey.showsInNotch)
    }

    public func setNotchSeconds(_ value: Double) {
        let clamped = min(Self.notchSecondsRange.upperBound, max(Self.notchSecondsRange.lowerBound, value))
        notchSeconds = clamped
        host?.preferences.setValue(clamped, forKey: StorageKey.notchSeconds)
    }

    public func setShortcut(_ shortcut: DropletKeyboardShortcut) {
        guard let host else { return }
        host.shortcuts.unregister(id: Self.pickShortcutID)
        registerPickShortcut(host, suggesting: shortcut)
        syncShortcut(with: host)
    }

    public func resetShortcut() {
        setShortcut(Self.defaultPickShortcut)
    }

    public func copyPalette() {
        guard let host, !recentColors.isEmpty else { return }
        let text = recentColors.map { $0.text(in: notation) }.joined(separator: "\n")
        if host.workspace.copyToPasteboard(text) {
            host.feedback.play(.tick)
        }
    }

    public func clearPalette() {
        recentColors = []
        activeColor = nil
        host?.preferences.setValue([SampledColor](), forKey: StorageKey.recentColors)
    }

    private func registerPickShortcut(_ host: DropletHost, suggesting shortcut: DropletKeyboardShortcut?) {
        host.shortcuts.register(
            id: Self.pickShortcutID,
            title: "Pick a color with Eyedropper",
            defaultShortcut: shortcut
        ) { [weak self] in
            self?.pickColor()
        }
    }

    private func syncShortcut(with host: DropletHost) {
        let current = host.shortcuts.currentShortcut(id: Self.pickShortcutID)
        pickShortcut = current
        host.preferences.setValue(current, forKey: StorageKey.shortcut)
    }

    private func remember(_ color: SampledColor, host: DropletHost) {
        recentColors = Palette.remembering(color, in: recentColors)
        activeColor = color
        host.preferences.setValue(recentColors, forKey: StorageKey.recentColors)
        if copiesAutomatically {
            _ = host.workspace.copyToPasteboard(color.text(in: notation))
        }
        showReadout(for: color)
        host.feedback.play(.drop)
    }

    private func restoreState(from host: DropletHost) {
        recentColors = host.preferences.value(forKey: StorageKey.recentColors, as: [SampledColor].self) ?? []
        if let saved = host.preferences.value(forKey: StorageKey.notation, as: String.self),
           let restored = ColorNotation(rawValue: saved) {
            notation = restored
        }
        copiesAutomatically = host.preferences.value(forKey: StorageKey.copiesAutomatically, default: true)
        showsMenuBarItem = host.preferences.value(forKey: StorageKey.showsMenuBarItem, default: false)
        showsInNotch = host.preferences.value(forKey: StorageKey.showsInNotch, default: true)
        setNotchSeconds(host.preferences.value(forKey: StorageKey.notchSeconds, default: 2.5))
    }

    private func showReadout(for color: SampledColor) {
        guard let host, showsInNotch else { return }
        let notation = notation
        let request = DropletHUDRequest(
            id: "eyedropper.readout",
            duration: notchSeconds,
            accessibilityLabel: color.text(in: notation),
            isExpanded: true,
            expandedContentHeight: 56
        ) {
            NotchReadout(color: color, notation: notation)
        } expanded: {
            NotchReadoutCard(color: color, notation: notation)
        }
        _ = host.hud.present(request)
    }
}

enum StorageKey {
    static let recentColors = "recentColors"
    static let notation = "notation"
    static let copiesAutomatically = "copiesAutomatically"
    static let showsMenuBarItem = "showsMenuBarItem"
    static let showsInNotch = "showsInNotch"
    static let notchSeconds = "notchSeconds"
    static let shortcut = "shortcut"
}
