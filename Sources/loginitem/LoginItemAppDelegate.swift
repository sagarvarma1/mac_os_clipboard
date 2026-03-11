import AppKit

final class LoginItemAppDelegate: NSObject, NSApplicationDelegate {
    private var observer: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { _ in
            if self.isMainAppRunning() {
                NSApp.terminate(nil)
            }
        }

        if isMainAppRunning() {
            NSApp.terminate(nil)
        }
    }

    deinit {
        if let observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    private func isMainAppRunning() -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: AppIdentifiers.mainApp).isEmpty
    }
}
