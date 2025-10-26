import AppKit
import SwiftUI

final class MenuBarManager: NSObject {
    // MARK: - Singleton
    static let shared = MenuBarManager()

    // MARK: - Properties
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var isPopoverShown: Bool = false

    // MARK: - Initialization
    private override init() {
        super.init()
    }

    // MARK: - Setup
    func setup() {
        print("🔧 MenuBarManager: setup() called")
        // Use fixed length to prevent jumping when text changes
        // Icon (20) + "00:00" (5 chars) + 5 chars event name = ~150 pixels
        statusItem = NSStatusBar.system.statusItem(withLength: 150)
        print("📍 MenuBarManager: statusItem created: \(statusItem != nil)")

        if let button = statusItem?.button {
            print("📍 MenuBarManager: button found, setting icon and title")
            button.image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "TimeDonut")
            button.title = " ..."
            button.imagePosition = .imageLeading
            button.alignment = .left
            // Use monospace font for consistent character width
            button.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
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
            // Skip updates while popover is shown to prevent display glitches
            guard !self.isPopoverShown else { return }
            self.statusItem?.button?.title = " \(title)"
            NSLog("🔄 MenuBarManager: updateTitle called with '\(title)'")
        }
    }

    func showPopover<Content: View>(with contentView: Content) {
        guard let button = statusItem?.button else { return }

        if popover == nil {
            popover = NSPopover()
            popover?.contentSize = NSSize(width: 700, height: 400)
            popover?.behavior = .transient
            popover?.delegate = self
        }

        popover?.contentViewController = NSHostingController(rootView: contentView)
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        isPopoverShown = true
    }

    func hidePopover() {
        popover?.performClose(nil)
        isPopoverShown = false
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

// MARK: - NSPopoverDelegate
extension MenuBarManager: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        isPopoverShown = false
        // Reset display to initial state after closing popover
        NotificationCenter.default.post(name: .resetMenuBarDisplay, object: nil)
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let showPopover = Notification.Name("showPopover")
    static let refreshCalendar = Notification.Name("refreshCalendar")
    static let signOut = Notification.Name("signOut")
    static let updateMenuBarTitle = Notification.Name("updateMenuBarTitle")
    static let resetMenuBarDisplay = Notification.Name("resetMenuBarDisplay")
}
