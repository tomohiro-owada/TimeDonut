import Foundation

/// Client for interacting with Google Calendar API v3
final class CalendarAPIClient {
    // MARK: - Properties
    private let session = URLSession.shared
    private let baseURL = "https://www.googleapis.com/calendar/v3"

    // MARK: - Initialization
    init() {}

    // MARK: - Public Methods

    /// Fetches calendar events from Google Calendar API
    /// - Parameters:
    ///   - accessToken: OAuth 2.0 access token for authorization
    ///   - timeMin: Minimum start time for events (inclusive)
    ///   - timeMax: Maximum start time for events (exclusive)
    /// - Returns: Array of CalendarEvent objects
    /// - Throws: CalendarError if the request fails
    func fetchEvents(
        accessToken: String,
        timeMin: Date,
        timeMax: Date
    ) async throws -> [CalendarEvent] {
        NSLog("🌐 CalendarAPIClient: fetchEvents() called")

        // Build URL with query parameters
        let url = URL(string: "\(baseURL)/calendars/primary/events")!

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        // Configure ISO8601 formatter for date parameters
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        components.queryItems = [
            URLQueryItem(name: "timeMin", value: formatter.string(from: timeMin)),
            URLQueryItem(name: "timeMax", value: formatter.string(from: timeMax)),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "maxResults", value: "50")
        ]

        guard let requestURL = components.url else {
            throw CalendarError.apiError("Invalid URL construction")
        }

        NSLog("🌐 Request URL: \(requestURL.absoluteString)")

        // Configure request with authorization header
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = Constants.Timing.apiTimeout

        // Execute request
        NSLog("🌐 Sending request to Google Calendar API...")
        let (data, response) = try await session.data(for: request)

        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CalendarError.networkError
        }

        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200:
            // Success - continue to decode
            break
        case 401:
            throw CalendarError.apiError("Unauthorized - Invalid or expired access token")
        case 403:
            throw CalendarError.apiError("Forbidden - Insufficient permissions")
        case 429:
            throw CalendarError.apiError("Rate limit exceeded - Too many requests")
        case 500...599:
            throw CalendarError.apiError("Server error (HTTP \(httpResponse.statusCode))")
        default:
            throw CalendarError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Decode JSON response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let calendarResponse = try decoder.decode(CalendarResponse.self, from: data)

        // Convert API response to domain models
        return calendarResponse.items.compactMap { $0.toCalendarEvent() }
    }
}

// MARK: - Response Models

/// Root response object from Google Calendar API
struct CalendarResponse: Codable {
    let items: [CalendarEventResponse]
}

/// Individual calendar event response from Google Calendar API
struct CalendarEventResponse: Codable {
    let id: String
    let summary: String?
    let start: EventDateTime
    let end: EventDateTime
    let colorId: String?
    let status: String?
    let location: String?
    let description: String?

    /// Converts API response to domain model
    /// - Returns: CalendarEvent if conversion is successful, nil otherwise
    func toCalendarEvent() -> CalendarEvent? {
        guard let summary = summary else {
            return nil
        }

        // Determine if this is an all-day event
        let isAllDay = start.dateTime == nil

        // Parse dates based on event type
        let startDate: Date
        let endDate: Date

        if isAllDay {
            // All-day events use date strings
            guard let startDateString = start.date,
                  let endDateString = end.date else {
                return nil
            }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]

            guard let parsedStart = formatter.date(from: startDateString),
                  let parsedEnd = formatter.date(from: endDateString) else {
                return nil
            }

            startDate = parsedStart
            endDate = parsedEnd
        } else {
            // Regular events use dateTime
            guard let parsedStart = start.dateTime,
                  let parsedEnd = end.dateTime else {
                return nil
            }

            startDate = parsedStart
            endDate = parsedEnd
        }

        // Parse event status
        let eventStatus = EventStatus(rawValue: status ?? "confirmed") ?? .confirmed

        return CalendarEvent(
            id: id,
            summary: summary,
            startTime: startDate,
            endTime: endDate,
            colorId: colorId,
            calendarId: "primary",
            isAllDay: isAllDay,
            status: eventStatus,
            location: location,
            description: description
        )
    }
}

/// Date/time representation in Google Calendar API
struct EventDateTime: Codable {
    let dateTime: Date?
    let date: String?
}
