import AppKit
import SwiftUI

final class MenuBarManager: NSObject {
    // MARK: - Singleton
    static let shared = MenuBarManager()

    // MARK: - Properties
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    // MARK: - Initialization
    private override init() {
        super.init()
    }

    // MARK: - Setup
    func setup() {
        print("🔧 MenuBarManager: setup() called")
        // Use fixed length to prevent jumping when text changes
        // Icon (20) + "00:00" (5 chars) + 3 chars event name = ~120 pixels
        statusItem = NSStatusBar.system.statusItem(withLength: 120)
        print("📍 MenuBarManager: statusItem created: \(statusItem != nil)")

        if let button = statusItem?.button {
            print("📍 MenuBarManager: button found, setting icon and title")
            button.image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "TimeDonut")
            button.title = " ..."
            button.imagePosition = .imageLeading
            button.alignment = .left
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            print("✅ MenuBarManager: Menu bar button configured")
        } else {
            print("❌ MenuBarManager: Failed to get button from statusItem")
        }
    }

    // MARK: - Public Methods
    func updateTitle(_ title: String) {
        DispatchQueue.main.async {
            self.statusItem?.button?.title = " \(title)"
            NSLog("🔄 MenuBarManager: updateTitle called with '\(title)'")
        }
    }

    func showPopover<Content: View>(with contentView: Content) {
        guard let button = statusItem?.button else { return }

        if popover == nil {
            popover = NSPopover()
            popover?.contentSize = NSSize(width: 360, height: 600)
            popover?.behavior = .transient
        }

        popover?.contentViewController = NSHostingController(rootView: contentView)
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    func hidePopover() {
        popover?.performClose(nil)
    }

    // MARK: - Actions
    @objc private func togglePopover() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            if popover?.isShown == true {
                hidePopover()
            } else {
                NotificationCenter.default.post(name: .showPopover, object: nil)
            }
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "更新", action: #selector(refresh), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "サインアウト", action: #selector(signOut), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q"))

        // Set target for menu items
        menu.items.forEach { $0.target = self }

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func refresh() {
        NotificationCenter.default.post(name: .refreshCalendar, object: nil)
    }

    @objc private func signOut() {
        NotificationCenter.default.post(name: .signOut, object: nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let showPopover = Notification.Name("showPopover")
    static let refreshCalendar = Notification.Name("refreshCalendar")
    static let signOut = Notification.Name("signOut")
    static let updateMenuBarTitle = Notification.Name("updateMenuBarTitle")
}
