import AppKit
import Foundation

enum ClipboardCapture {
    case text(String)
    case image(NSImage, Data)
}

@MainActor
final class ClipboardWatcher {
    private let pasteboard: NSPasteboard
    private var timer: Timer?
    private var lastChangeCount: Int

    var onCapture: ((ClipboardCapture) -> Void)?

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
        self.lastChangeCount = pasteboard.changeCount
    }

    func start(interval: TimeInterval = 0.4) {
        stop()
        lastChangeCount = pasteboard.changeCount
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollPasteboard()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func pollPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        lastChangeCount = pasteboard.changeCount

        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            onCapture?(.text(text))
            return
        }

        if let (image, sourceData) = readImagePayload() {
            onCapture?(.image(image, sourceData))
        }
    }

    private func readImagePayload() -> (NSImage, Data)? {
        let preferredTypes: [NSPasteboard.PasteboardType] = [.png, .tiff]
        for type in preferredTypes {
            if let data = pasteboard.data(forType: type),
               let image = NSImage(data: data) {
                return (image, data)
            }
        }

        if let images = pasteboard.readObjects(forClasses: [NSImage.self]) as? [NSImage],
           let image = images.first,
           let pngData = image.pngData {
            return (image, pngData)
        }

        return nil
    }
}
