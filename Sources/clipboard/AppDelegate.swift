import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep this app as a regular macOS app so Dock icon + menu bar icon are both visible.
        NSApp.setActivationPolicy(.regular)
    }
}
