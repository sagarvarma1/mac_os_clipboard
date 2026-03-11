import SwiftUI

enum AppSceneID {
    static let historyWindow = "history-window"
}

@main
struct ClipboardApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("Clipboard History", id: AppSceneID.historyWindow) {
            HistoryWindowView()
                .environmentObject(appState)
                .frame(minWidth: 620, minHeight: 440)
        }

        MenuBarExtra("Clipboard", systemImage: "clipboard") {
            MenuBarView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
                .frame(width: 340, height: 180)
        }
    }
}
