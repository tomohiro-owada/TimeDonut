import Foundation

/// Manager for fetching and caching calendar events from Cloud Functions
final class CalendarManager {
    // MARK: - Singleton
    static let shared = CalendarManager()

    // MARK: - Dependencies
    private let authManager = GoogleAuthManager.shared

    // MARK: - Cache
    private var cachedEvents: [CalendarEvent] = []
    private var lastFetchTime: Date?

    // MARK: - Private Properties
    private let calendar = Calendar.current
    private let eventsURL = Constants.CloudFunctions.eventsURL

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// Fetches calendar events from Cloud Functions
    /// - Returns: Array of CalendarEvent objects, filtered and sorted
    /// - Throws: CalendarError if the fetch operation fails
    func fetchEvents() async throws -> [CalendarEvent] {
        NSLog("📅 CalendarManager: fetchEvents() called")

        // Get user ID
        guard let userID = await authManager.currentUser?.userID else {
            NSLog("❌ No user ID available")
            throw CalendarError.notAuthenticated
        }
        NSLog("✅ User ID retrieved: \(userID)")

        // Calculate time range: today 0:00 to tomorrow 23:59
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        // Get end of tomorrow (2 days from start of today)
        guard let endOfTomorrow = calendar.date(byAdding: .day, value: 2, to: startOfDay) else {
            throw CalendarError.apiError("Failed to calculate date range")
        }

        NSLog("📅 Fetching events from \(startOfDay) to \(endOfTomorrow)")

        // Fetch events from Cloud Functions
        let events = try await fetchEventsFromCloudFunctions(
            userID: userID,
            timeMin: startOfDay,
            timeMax: endOfTomorrow
        )

        NSLog("✅ Received \(events.count) events from Cloud Functions")

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

    // MARK: - Private Methods

    /// Fetches events from Cloud Functions
    private func fetchEventsFromCloudFunctions(
        userID: String,
        timeMin: Date,
        timeMax: Date
    ) async throws -> [CalendarEvent] {
        var components = URLComponents(string: eventsURL)!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: ISO8601DateFormatter().string(from: timeMin)),
            URLQueryItem(name: "timeMax", value: ISO8601DateFormatter().string(from: timeMax))
        ]

        guard let url = components.url else {
            throw CalendarError.apiError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(userID)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = Constants.Timing.apiTimeout

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CalendarError.apiError("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            NSLog("❌ Cloud Functions returned status code: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                NSLog("❌ Error response: \(errorString)")
            }
            throw CalendarError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Parse response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let cloudFunctionsResponse = try decoder.decode(CloudFunctionsEventsResponse.self, from: data)

        // Convert to CalendarEvent objects
        return cloudFunctionsResponse.events.compactMap { item -> CalendarEvent? in
            guard let start = item.start.dateTime ?? parseDate(from: item.start.date) else {
                return nil
            }

            let end = item.end.dateTime ?? parseDate(from: item.end.date) ?? start.addingTimeInterval(3600)

            return CalendarEvent(
                id: item.id,
                summary: item.summary ?? "（タイトルなし）",
                startTime: start,
                endTime: end,
                colorId: item.colorId,
                calendarId: item.calendarId ?? "primary",
                isAllDay: item.start.dateTime == nil,
                status: EventStatus(rawValue: item.status) ?? .confirmed,
                location: item.location,
                description: item.description
            )
        }
    }

    /// Parses a date string from "yyyy-MM-dd" format
    private func parseDate(from dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
}

// MARK: - Supporting Types

/// Response structure from Cloud Functions /events endpoint
private struct CloudFunctionsEventsResponse: Codable {
    let events: [GoogleCalendarEvent]
}

/// Google Calendar event structure from Cloud Functions
private struct GoogleCalendarEvent: Codable {
    let id: String
    let summary: String?
    let start: EventDateTime
    let end: EventDateTime
    let status: String
    let colorId: String?
    let calendarId: String?
    let location: String?
    let description: String?
}

/// Event date/time structure
private struct EventDateTime: Codable {
    let dateTime: Date?
    let date: String?
}
