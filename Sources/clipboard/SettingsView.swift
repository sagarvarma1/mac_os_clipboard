import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { appState.launchAtLoginEnabled },
            set: { appState.setLaunchAtLoginEnabled($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Clipboard Manager")
                .font(.headline)
            Text("Stores the most recent 100 clipboard items, including images.")
                .foregroundStyle(.secondary)

            Text("Current items: \(appState.store.items.count)")
                .font(.subheadline)

            Toggle("Launch at login", isOn: launchAtLoginBinding)

            if let note = appState.launchAtLoginNote {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Button("Clear History", role: .destructive) {
                    appState.clearHistory()
                }
                .disabled(appState.store.items.isEmpty)
            }
        }
        .padding(16)
        .onAppear {
            appState.refreshLaunchAtLoginState()
        }
    }
}
