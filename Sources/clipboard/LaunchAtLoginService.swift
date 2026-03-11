import Foundation
import ServiceManagement

struct LaunchAtLoginService {
    private let service = SMAppService.loginItem(identifier: AppIdentifiers.loginItem)

    var isEnabled: Bool {
        service.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            guard service.status != .enabled else {
                return
            }
            try service.register()
            return
        }

        if service.status == .enabled || service.status == .requiresApproval {
            try service.unregister()
        }
    }

    func userMessageForCurrentStatus() -> String? {
        if service.status == .requiresApproval {
            return "Enable ClipboardLoginItem in System Settings > General > Login Items."
        }
        if service.status == .enabled || service.status == .notRegistered {
            return nil
        }
        return "Launch at login requires the signed ClipboardApp.app in /Applications."
    }
}
