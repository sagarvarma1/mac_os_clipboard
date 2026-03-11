import AppKit
import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var launchAtLoginEnabled = false
    @Published var launchAtLoginNote: String?

    let store: HistoryStore
    private let watcher: ClipboardWatcher
    private let launchAtLoginService: LaunchAtLoginService
    private var cancellables = Set<AnyCancellable>()

    init(
        store: HistoryStore = HistoryStore(),
        watcher: ClipboardWatcher = ClipboardWatcher(),
        launchAtLoginService: LaunchAtLoginService = LaunchAtLoginService()
    ) {
        self.store = store
        self.watcher = watcher
        self.launchAtLoginService = launchAtLoginService

        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        self.watcher.onCapture = { [weak self] capture in
            self?.handleCapture(capture)
        }
        self.watcher.start()
        refreshLaunchAtLoginState()
    }

    var filteredItems: [ClipboardItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return store.items
        }

        return store.items.filter { item in
            item.previewText.localizedCaseInsensitiveContains(query) ||
                item.textContent?.localizedCaseInsensitiveContains(query) == true
        }
    }

    func restore(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.kind {
        case .text:
            guard let text = item.textContent else {
                return
            }
            pasteboard.setString(text, forType: .string)

        case .image:
            guard let image = store.image(for: item) else {
                return
            }
            pasteboard.writeObjects([image])
        }
    }

    func clearHistory() {
        store.clearHistory()
    }

    func image(for item: ClipboardItem) -> NSImage? {
        store.image(for: item)
    }

    func refreshLaunchAtLoginState() {
        launchAtLoginEnabled = launchAtLoginService.isEnabled
        launchAtLoginNote = launchAtLoginService.userMessageForCurrentStatus()
    }

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        do {
            try launchAtLoginService.setEnabled(enabled)
        } catch {
            launchAtLoginNote = "Could not update login setting: \(error.localizedDescription)"
        }
        refreshLaunchAtLoginState()
    }

    private func handleCapture(_ capture: ClipboardCapture) {
        switch capture {
        case .text(let text):
            store.addText(text)
        case .image(let image, let sourceData):
            store.addImage(image, sourceData: sourceData)
        }
    }
}
