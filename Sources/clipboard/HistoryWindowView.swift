import SwiftUI

struct HistoryWindowView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Search clipboard history", text: $appState.searchText)
                    .textFieldStyle(.roundedBorder)

                Button("Clear All", role: .destructive) {
                    appState.clearHistory()
                }
                .disabled(appState.store.items.isEmpty)
            }

            if appState.filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No Clipboard Items")
                        .font(.headline)
                    Text("Copy text or an image to begin collecting history.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(appState.filteredItems) { item in
                    Button {
                        appState.restore(item)
                    } label: {
                        ClipboardRowView(item: item, image: appState.image(for: item))
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.inset)
            }
        }
        .padding(14)
    }
}

private struct ClipboardRowView: View {
    let item: ClipboardItem
    let image: NSImage?

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else if item.kind == .text {
                    Image(systemName: "text.alignleft")
                        .resizable()
                        .scaledToFit()
                        .padding(9)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 34, height: 34)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(item.createdAt, style: .time)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            Spacer(minLength: 4)
            Image(systemName: "arrowshape.turn.up.backward")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
