import AppKit
import Combine
import CryptoKit
import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []

    private let maxItems: Int
    private let rootDirectoryURL: URL
    private let metadataURL: URL
    private let imagesDirectoryURL: URL
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(maxItems: Int = 100, rootDirectoryURL: URL? = nil) {
        self.maxItems = maxItems

        if let rootDirectoryURL {
            self.rootDirectoryURL = rootDirectoryURL
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let containerName = Bundle.main.bundleIdentifier ?? "ClipboardManager"
            self.rootDirectoryURL = appSupport.appendingPathComponent(containerName, isDirectory: true)
        }

        self.metadataURL = self.rootDirectoryURL.appendingPathComponent("history.json", isDirectory: false)
        self.imagesDirectoryURL = self.rootDirectoryURL.appendingPathComponent("images", isDirectory: true)

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        createStorageIfNeeded()
        load()
    }

    func addText(_ text: String) {
        guard !text.isEmpty else {
            return
        }

        let fingerprint = Self.hash(data: Data(text.utf8))
        guard items.first?.fingerprint != fingerprint else {
            return
        }

        let item = ClipboardItem(
            id: UUID(),
            createdAt: Date(),
            kind: .text,
            previewText: Self.previewText(from: text),
            fingerprint: fingerprint,
            textContent: text,
            imageFileName: nil
        )

        insert(item)
    }

    func addImage(_ image: NSImage, sourceData: Data) {
        guard let pngData = image.pngData else {
            return
        }

        let fingerprint = Self.hash(data: sourceData)
        guard items.first?.fingerprint != fingerprint else {
            return
        }

        let id = UUID()
        let imageFileName = "\(id.uuidString).png"
        let imageURL = imagesDirectoryURL.appendingPathComponent(imageFileName, isDirectory: false)

        do {
            try pngData.write(to: imageURL, options: .atomic)
        } catch {
            return
        }

        let size = image.size
        let preview = "Image \(Int(size.width)) x \(Int(size.height))"
        let item = ClipboardItem(
            id: id,
            createdAt: Date(),
            kind: .image,
            previewText: preview,
            fingerprint: fingerprint,
            textContent: nil,
            imageFileName: imageFileName
        )

        insert(item)
    }

    func clearHistory() {
        items.forEach(removeImageFileIfNeeded(for:))
        items = []
        persist()
    }

    func image(for item: ClipboardItem) -> NSImage? {
        guard let imageFileName = item.imageFileName else {
            return nil
        }
        let imageURL = imagesDirectoryURL.appendingPathComponent(imageFileName, isDirectory: false)
        return NSImage(contentsOf: imageURL)
    }

    private func insert(_ item: ClipboardItem) {
        items.insert(item, at: 0)
        pruneIfNeeded()
        persist()
    }

    private func pruneIfNeeded() {
        guard items.count > maxItems else {
            return
        }

        let removed = Array(items.suffix(from: maxItems))
        items = Array(items.prefix(maxItems))
        removed.forEach(removeImageFileIfNeeded(for:))
    }

    private func createStorageIfNeeded() {
        do {
            try fileManager.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true)
        } catch {
            // Keep running with in-memory state if local persistence cannot be created.
        }
    }

    private func load() {
        guard fileManager.fileExists(atPath: metadataURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: metadataURL)
            let loadedItems = try decoder.decode([ClipboardItem].self, from: data)
            items = loadedItems.filter { item in
                guard item.kind == .image else {
                    return true
                }
                guard let imageFileName = item.imageFileName else {
                    return false
                }
                let imagePath = imagesDirectoryURL.appendingPathComponent(imageFileName, isDirectory: false).path
                return fileManager.fileExists(atPath: imagePath)
            }
            pruneIfNeeded()
            persist()
        } catch {
            items = []
        }
    }

    private func persist() {
        do {
            let data = try encoder.encode(items)
            try data.write(to: metadataURL, options: .atomic)
        } catch {
            // Keep app functional even if persistence fails.
        }
    }

    private func removeImageFileIfNeeded(for item: ClipboardItem) {
        guard let imageFileName = item.imageFileName else {
            return
        }

        let imageURL = imagesDirectoryURL.appendingPathComponent(imageFileName, isDirectory: false)
        try? fileManager.removeItem(at: imageURL)
    }

    private static func hash(data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func previewText(from text: String) -> String {
        let normalized = text.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.count > 100 else {
            return normalized
        }
        return String(normalized.prefix(100)) + "..."
    }
}
