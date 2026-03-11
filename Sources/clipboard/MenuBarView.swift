import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var appState: AppState

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

            Divider()

            HStack {
                Button("Open Full Window") {
                    openWindow(id: AppSceneID.historyWindow)
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
}
