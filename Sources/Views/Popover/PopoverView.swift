//
//  PopoverView.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import SwiftUI

/// Main popover view that displays calendar events or sign-in screen
/// This is a minimal implementation for testing the build
struct PopoverView: View {
    // MARK: - Properties

    /// Application state view model for authentication management
    @ObservedObject var appState: AppStateViewModel

    /// Events view model for calendar events
    @ObservedObject var eventsState: EventsViewModel

    /// Clock offset for donut clock (what hour is at the top)
    @State private var clockOffset: Int = 0

    // MARK: - Body

    var body: some View {
        VStack {
            if !appState.authState.isAuthenticated {
                // Not authenticated - show sign-in view
                SignInView(appState: appState)
            } else {
                // Authenticated - show events
                authenticatedView
            }
        }
        .frame(width: 700, height: 400)
    }

    // MARK: - Authenticated View

    private var authenticatedView: some View {
        HStack(spacing: 0) {
            // Left: Donut Clock
            if eventsState.isLoading {
                ProgressView("読み込み中...")
                    .frame(width: 360, height: 400)
            } else {
                VStack {
                    DonutClockView(
                        events: eventsState.events,
                        clockOffset: clockOffset,
                        nextEvent: eventsState.nextEvent
                    )

                    // Clock offset selector
                    Picker("", selection: $clockOffset) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)時").tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 70)
                    .font(.system(size: 11))
                    .padding(.top, 8)
                }
                .frame(width: 360)
                .padding(.vertical, 12)
            }

            Divider()

            // Right: Header + Events List + Footer
            VStack(spacing: 12) {
                // Header with user info
                VStack(spacing: 8) {
                    if let email = appState.authState.userEmail {
                        Text(email)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Text("今日の予定: \(eventsState.events.count)件")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.top, 16)

                Divider()

                // Events list (scrollable)
                if eventsState.events.isEmpty {
                    VStack(spacing: 12) {
                        Text("🍩")
                            .font(.system(size: 48))
                        Text("予定がありません")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(eventsState.events) { event in
                                eventRow(for: event)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }

                Spacer()

                Divider()

                // Footer with refresh and sign-out buttons
                HStack {
                    Button(action: {
                        Task {
                            await eventsState.refresh()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("更新")
                                .font(.system(size: 12))
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .padding(.leading, 12)

                    Spacer()

                    Button(action: {
                        appState.signOut()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("サインアウト")
                                .font(.system(size: 12))
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 12)
                }
                .padding(.bottom, 12)
            }
            .frame(width: 340)
        }
    }

    // MARK: - Event Row

    private func eventRow(for event: CalendarEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(event.color)
                    .frame(width: 8, height: 8)

                Text(event.summary)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                Spacer()

                if event.isOngoing {
                    Text("開催中")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(4)
                }
            }

            HStack(spacing: 4) {
                Text(formatTime(event.startTime))
                Text("-")
                Text(formatTime(event.endTime))
                Text("(\(event.durationFormatted))")
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }

    // MARK: - Helper Methods

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    PopoverView(
        appState: AppStateViewModel(),
        eventsState: EventsViewModel()
    )
}
