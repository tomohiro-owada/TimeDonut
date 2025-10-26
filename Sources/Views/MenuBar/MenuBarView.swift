//
//  MenuBarView.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import SwiftUI

/// Minimal menu bar view that displays next event countdown
/// This is a temporary implementation for testing the build
struct MenuBarView: View {
    // MARK: - Properties

    /// Events view model to observe next event changes
    @ObservedObject var eventsState: EventsViewModel

    // MARK: - Body

    var body: some View {
        Text(eventsState.timeUntilNextEvent)
            .font(.system(size: 13))
    }
}

// MARK: - Preview

#Preview {
    MenuBarView(eventsState: EventsViewModel())
}
