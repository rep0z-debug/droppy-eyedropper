import AppKit
import DroppyKit
import SwiftUI

@MainActor
private final class ShortcutRecorder: ObservableObject {
    @Published private(set) var isRecording = false
    private var monitor: Any?

    func toggle(onCapture: @escaping (DropletKeyboardShortcut) -> Void) {
        if isRecording {
            stop()
        } else {
            start(onCapture: onCapture)
        }
    }

    func start(onCapture: @escaping (DropletKeyboardShortcut) -> Void) {
        stop()
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53 {
                self.stop()
                return nil
            }
            let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
            let bindable: NSEvent.ModifierFlags = [.command, .option, .control]
            guard !modifiers.isDisjoint(with: bindable) else {
                NSSound.beep()
                return nil
            }
            onCapture(DropletKeyboardShortcut(keyCode: event.keyCode, modifiers: modifiers.rawValue))
            self.stop()
            return nil
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        isRecording = false
    }
}

struct ShortcutField: View {
    let shortcut: DropletKeyboardShortcut?
    let onChange: (DropletKeyboardShortcut) -> Void

    @StateObject private var recorder = ShortcutRecorder()

    var body: some View {
        Button {
            recorder.toggle(onCapture: onChange)
        } label: {
            Text(caption)
                .monospacedDigit()
        }
        .buttonStyle(DroppyQuietButtonStyle(size: .small))
        .help("Click, then press the keys you want")
        .onDisappear { recorder.stop() }
    }

    private var caption: String {
        if recorder.isRecording { return "Press keys…" }
        return shortcut.map(ShortcutText.label) ?? "Not set"
    }
}
