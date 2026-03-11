import Foundation

enum ClipboardItemKind: String, Codable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    let kind: ClipboardItemKind
    let previewText: String
    let fingerprint: String
    let textContent: String?
    let imageFileName: String?
}
