//
//  AppDelegate.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import AppKit
import SwiftUI

/// Application delegate for handling macOS-specific app lifecycle events
/// Configures the app as a menu bar accessory and manages the menu bar interface
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties
    var eventsViewModel: EventsViewModel?

    // MARK: - Application Lifecycle

    /// Called when the application has finished launching
    /// Sets up the menu bar interface and hides the app from the Dock
    /// - Parameter notification: The notification containing launch information
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("🚀 AppDelegate: applicationDidFinishLaunching called")

        // Hide from Dock - this is a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        NSLog("✅ AppDelegate: Set activation policy to .accessory")

        // Setup menu bar item with MenuBarManager
        MenuBarManager.shared.setup()
        NSLog("✅ AppDelegate: MenuBarManager setup completed")

        // Setup menu bar title updates
        setupMenuBarUpdates()
    }

    private func setupMenuBarUpdates() {
        // Subscribe to timeUntilNextEvent changes
        NotificationCenter.default.addObserver(
            forName: .updateMenuBarTitle,
            object: nil,
            queue: .main
        ) { notification in
            if let title = notification.object as? String {
                MenuBarManager.shared.updateTitle(title)
            }
        }
    }

    /// Called when the application is about to terminate
    /// Performs cleanup operations before the app exits
    /// - Parameter notification: The notification containing termination information
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup resources if needed
        // Currently no cleanup required
    }
}
