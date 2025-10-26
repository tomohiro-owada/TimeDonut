import Foundation

/// Manager for fetching and caching calendar events from Google Calendar
final class CalendarManager {
    // MARK: - Singleton
    static let shared = CalendarManager()

    // MARK: - Dependencies
    private let authManager = GoogleAuthManager.shared
    private let apiClient = CalendarAPIClient()

    // MARK: - Cache
    private var cachedEvents: [CalendarEvent] = []
    private var lastFetchTime: Date?

    // MARK: - Private Properties
    private let calendar = Calendar.current

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// Fetches calendar events from Google Calendar API
    /// - Returns: Array of CalendarEvent objects, filtered and sorted
    /// - Throws: CalendarError if the fetch operation fails
    func fetchEvents() async throws -> [CalendarEvent] {
        NSLog("📅 CalendarManager: fetchEvents() called")

        // Refresh token if needed
        try await authManager.refreshAccessTokenIfNeeded()
        NSLog("✅ Token refreshed if needed")

        // Get access token
        guard let accessToken = await authManager.currentUser?.accessToken else {
            NSLog("❌ No access token available")
            throw CalendarError.notAuthenticated
        }
        NSLog("✅ Access token retrieved")

        // Calculate time range: today 0:00 to tomorrow 23:59
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        // Get end of tomorrow (2 days from start of today)
        guard let endOfTomorrow = calendar.date(byAdding: .day, value: 2, to: startOfDay) else {
            throw CalendarError.apiError("Failed to calculate date range")
        }

        NSLog("📅 Fetching events from \(startOfDay) to \(endOfTomorrow)")

        // Fetch events from API
        let events = try await apiClient.fetchEvents(
            accessToken: accessToken,
            timeMin: startOfDay,
            timeMax: endOfTomorrow
        )

        NSLog("✅ Received \(events.count) events from API")

        // Update cache
        cachedEvents = events
        lastFetchTime = now

        // Filter cancelled events and sort by start time
        return events
            .filter { $0.status != .cancelled }
            .sorted { $0.startTime < $1.startTime }
    }

    /// Returns cached events without making an API call
    /// - Returns: Array of cached CalendarEvent objects
    func getCachedEvents() -> [CalendarEvent] {
        return cachedEvents
    }

    /// Returns the last time events were fetched
    /// - Returns: Date of last fetch, or nil if never fetched
    func getLastFetchTime() -> Date? {
        return lastFetchTime
    }

    /// Clears the event cache
    func clearCache() {
        cachedEvents = []
        lastFetchTime = nil
    }
}
