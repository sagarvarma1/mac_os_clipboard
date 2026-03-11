import AppKit
import SwiftUI

struct LoginItemMenuBarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var statusMessage: String?

    private let maxVisibleItems = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Clipboard")
                .font(.headline)

            if appState.store.items.isEmpty {
                Text("No clipboard items yet")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 6)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(appState.store.items.prefix(maxVisibleItems))) { item in
                            Button {
                                appState.restore(item)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: item.kind == .text ? "text.alignleft" : "photo")
                                        .foregroundStyle(.secondary)
                                    Text(item.previewText)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 260)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Button("Open Clipboard App") {
                    openMainApp()
                }
                Spacer()
                Button("Clear") {
                    appState.clearHistory()
                }
                .disabled(appState.store.items.isEmpty)
            }
        }
        .padding(12)
        .frame(width: 360)
    }

    private func openMainApp() {
        guard let mainAppURL = mainAppURL() else {
            statusMessage = "Could not locate ClipboardApp.app."
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: mainAppURL, configuration: configuration) { _, error in
            if let error {
                statusMessage = "Failed to open app: \(error.localizedDescription)"
                return
            }
            NSApp.terminate(nil)
        }
    }

    private func mainAppURL() -> URL? {
        // Helper path: .../ClipboardApp.app/Contents/Library/LoginItems/ClipboardLoginItem.app
        let helperURL = Bundle.main.bundleURL
        let candidate = helperURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        guard candidate.pathExtension == "app" else {
            return NSWorkspace.shared.urlForApplication(withBundleIdentifier: AppIdentifiers.mainApp)
        }
        return candidate
    }
}
