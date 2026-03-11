import SwiftUI

@main
struct ClipboardLoginItemApp: App {
    @NSApplicationDelegateAdaptor(LoginItemAppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "clipboard") {
            LoginItemMenuBarView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
}
