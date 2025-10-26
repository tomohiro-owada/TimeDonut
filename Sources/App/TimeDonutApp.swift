//
//  TimeDonutApp.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import SwiftUI

/// Main application entry point for TimeDonut
/// TimeDonut is a menu bar app that displays Google Calendar events in a donut chart format
@main
struct TimeDonutApp: App {
    // MARK: - Properties

    /// Adapts the AppDelegate to handle NSApplicationDelegate lifecycle events
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// Main application state manager for authentication and user session
    @StateObject var appState = AppStateViewModel()

    /// Events manager for fetching and displaying calendar events
    @StateObject var eventsState = EventsViewModel()

    // MARK: - Initialization

    init() {
        print("🎯 TimeDonutApp: init() called")
        // Setup notification observers
        setupNotificationObservers()
        print("✅ TimeDonutApp: Notification observers set up")
    }

    // MARK: - Body

    var body: some Scene {
        // Empty settings scene - menu bar is managed by MenuBarManager
        Settings {
            EmptyView()
        }
    }

    // MARK: - Notification Setup

    private func setupNotificationObservers() {
        // Observe show popover notification
        NotificationCenter.default.addObserver(
            forName: .showPopover,
            object: nil,
            queue: .main
        ) { [self] _ in
            MenuBarManager.shared.showPopover(
                with: PopoverView(appState: appState, eventsState: eventsState)
            )
        }

        // Observe refresh calendar notification
        NotificationCenter.default.addObserver(
            forName: .refreshCalendar,
            object: nil,
            queue: .main
        ) { [self] _ in
            Task { @MainActor in
                await eventsState.refresh()
            }
        }

        // Observe sign out notification
        NotificationCenter.default.addObserver(
            forName: .signOut,
            object: nil,
            queue: .main
        ) { [self] _ in
            Task { @MainActor in
                appState.signOut()
            }
        }
    }
}
