import Foundation

/// ViewModel for managing calendar events and countdown timer
@MainActor
final class EventsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var events: [CalendarEvent] = []
    @Published var nextEvent: CalendarEvent?
    @Published var timeUntilNextEvent: String = "予定なし"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let calendarManager: CalendarManager

    // MARK: - Timer Properties
    private var updateTimer: Timer?
    private var syncTimer: Timer?
    private var scrollTimer: Timer?

    // MARK: - Scroll Properties
    private var fullText: String = "予定なし"
    private var scrollIndex: Int = 0
    private var timePrefix: String = "" // Fixed time part (e.g., "3分後：")
    private var eventName: String = "予定なし" // Scrolling event name part

    // MARK: - Initialization
    init(calendarManager: CalendarManager = .shared) {
        self.calendarManager = calendarManager
        startTimers()
        setupNotifications()
    }

    deinit {
        // Note: deinit is not isolated to MainActor, so we invalidate timers directly
        updateTimer?.invalidate()
        syncTimer?.invalidate()
        scrollTimer?.invalidate()
    }

    // MARK: - Public Methods

    /// Fetches events from the calendar manager
    func fetchEvents() async {
        isLoading = true
        defer { isLoading = false }

        do {
            events = try await calendarManager.fetchEvents()
            updateNextEvent()
            // Reset scroll index when calendar data is refreshed
            scrollIndex = 0
            errorMessage = nil
            NSLog("🔄 EventsViewModel: Calendar fetched, reset scroll index")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Refreshes events (wrapper for fetchEvents)
    func refresh() async {
        await fetchEvents()
    }

    // MARK: - Private Methods

    /// Setup notification observers
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .resetMenuBarDisplay,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.scrollIndex = 0
                NSLog("🔄 EventsViewModel: Reset scroll index to 0")
            }
        }
    }

    /// Starts the update and sync timers
    private func startTimers() {
        // UI update timer (1 second interval)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimeUntilNextEvent()
            }
        }

        // Data sync timer (300 seconds / 5 minutes interval)
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchEvents()
            }
        }

        // Scroll timer (0.5 second interval for marquee effect)
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scrollText()
            }
        }

        // Initial fetch
        Task { @MainActor in
            await fetchEvents()
        }
    }

    /// Stops and invalidates all timers
    private func stopTimers() {
        updateTimer?.invalidate()
        updateTimer = nil
        syncTimer?.invalidate()
        syncTimer = nil
        scrollTimer?.invalidate()
        scrollTimer = nil
    }

    /// Scrolls the text for marquee effect
    private func scrollText() {
        guard eventName.count > 0 else {
            NSLog("⚠️ scrollText: eventName is empty")
            return
        }

        // Convert half-width to full-width for consistent display
        let fullWidthEventName = convertToFullWidth(eventName)

        // Display 5 characters of event name after time prefix
        let eventNameDisplayLength = 5

        if fullWidthEventName.count <= eventNameDisplayLength {
            // Event name fits without scrolling
            let displayText = timePrefix + fullWidthEventName
            timeUntilNextEvent = displayText

            NotificationCenter.default.post(
                name: .updateMenuBarTitle,
                object: displayText
            )
            return
        }

        // Scroll: slide through the text, then fade out at the end
        let totalSteps = fullWidthEventName.count + 1 // +1 for blank state

        let scrollingPart: String
        if scrollIndex < fullWidthEventName.count {
            let startIdx = fullWidthEventName.index(fullWidthEventName.startIndex, offsetBy: scrollIndex)
            let remainingChars = fullWidthEventName.distance(from: startIdx, to: fullWidthEventName.endIndex)
            let charsToShow = min(eventNameDisplayLength, remainingChars)
            let endIdx = fullWidthEventName.index(startIdx, offsetBy: charsToShow)
            let text = String(fullWidthEventName[startIdx..<endIdx])
            // Pad with full-width spaces (　) to keep width constant
            let spacesNeeded = eventNameDisplayLength - charsToShow
            scrollingPart = text + String(repeating: "　", count: spacesNeeded)
        } else {
            // Blank state before looping back (5 full-width spaces)
            scrollingPart = String(repeating: "　", count: eventNameDisplayLength)
        }

        let displayText = timePrefix + scrollingPart
        timeUntilNextEvent = displayText

        // Notify MenuBarManager to update title
        NotificationCenter.default.post(
            name: .updateMenuBarTitle,
            object: displayText
        )

        NSLog("📜 Scroll: prefix='\(timePrefix)', eventName='\(eventName)', displayed='\(displayText)'")

        // Increment index AFTER displaying (so we start from index 0)
        scrollIndex = (scrollIndex + 1) % totalSteps
    }

    /// Updates the next event from the current events list
    private func updateNextEvent() {
        // Find the next event (either ongoing or upcoming)
        nextEvent = events
            .filter { !$0.isPast }
            .sorted { $0.startTime < $1.startTime }
            .first

        updateTimeUntilNextEvent()
    }

    /// Updates the time until next event string
    private func updateTimeUntilNextEvent() {
        let previousEventName = eventName

        guard let event = nextEvent else {
            timePrefix = ""
            eventName = "予定なし"
            // Only reset scroll if event changed
            if previousEventName != eventName {
                scrollIndex = 0
            }
            return
        }

        // Check if event is currently ongoing
        if event.isOngoing {
            timePrefix = "開催中 "
            eventName = event.summary
            // Only reset scroll if event changed
            if previousEventName != eventName {
                scrollIndex = 0
            }
            return
        }

        // Calculate time until event starts
        guard let timeInterval = event.timeUntilStart else {
            timePrefix = ""
            eventName = "予定なし"
            // Only reset scroll if event changed
            if previousEventName != eventName {
                scrollIndex = 0
            }
            return
        }

        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60

        // Format time prefix in clock format (HH:MM) with space
        if hours > 0 || minutes > 0 {
            timePrefix = String(format: "%02d:%02d ", hours, minutes)
        } else {
            timePrefix = "00:00 "
        }

        eventName = event.summary
        // Only reset scroll if event changed
        if previousEventName != eventName {
            scrollIndex = 0
        }
    }

    /// Convert half-width characters to full-width for consistent display
    private func convertToFullWidth(_ text: String) -> String {
        var result = ""
        for char in text {
            let scalar = char.unicodeScalars.first!
            // Convert ASCII alphanumerics and symbols to full-width
            if scalar.value >= 0x0021 && scalar.value <= 0x007E {
                let fullWidth = UnicodeScalar(scalar.value - 0x0021 + 0xFF01)!
                result.append(String(fullWidth))
            } else {
                result.append(char)
            }
        }
        return result
    }
}
