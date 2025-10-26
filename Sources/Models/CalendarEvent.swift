import Foundation
import SwiftUI

struct CalendarEvent: Identifiable, Codable, Equatable {
    // MARK: - Properties
    let id: String
    let summary: String
    let startTime: Date
    let endTime: Date
    let colorId: String?
    let calendarId: String
    let isAllDay: Bool
    let status: EventStatus
    let location: String?
    let description: String?

    // MARK: - Computed Properties
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)時間\(minutes > 0 ? "\(minutes)分" : "")"
        } else {
            return "\(minutes)分"
        }
    }

    var isOngoing: Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }

    var isPast: Bool {
        Date() >= endTime
    }

    var timeUntilStart: TimeInterval? {
        guard !isOngoing && !isPast else { return nil }
        return startTime.timeIntervalSinceNow
    }

    var color: Color {
        GoogleCalendarColors.color(for: colorId)
    }

    // MARK: - Methods
    func angleRange(for hour: Int) -> (start: Double, end: Double) {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)

        let startAngle = Double(startHour % 12) / 12.0 * 360.0 +
                        Double(startMinute) / 60.0 * 30.0
        let endAngle = Double(endHour % 12) / 12.0 * 360.0 +
                      Double(endMinute) / 60.0 * 30.0

        return (startAngle, endAngle)
    }
}

// MARK: - EventStatus
enum EventStatus: String, Codable {
    case confirmed
    case tentative
    case cancelled
}

// MARK: - GoogleCalendarColors
enum GoogleCalendarColors {
    static func color(for colorId: String?) -> Color {
        guard let colorId = colorId else {
            return .blue
        }

        switch colorId {
        case "1": return Color(red: 0.64, green: 0.76, blue: 0.96) // Lavender
        case "2": return Color(red: 0.60, green: 0.87, blue: 0.68) // Sage
        case "3": return Color(red: 0.78, green: 0.63, blue: 0.89) // Grape
        case "4": return Color(red: 1.00, green: 0.74, blue: 0.67) // Flamingo
        case "5": return Color(red: 1.00, green: 0.92, blue: 0.60) // Banana
        case "6": return Color(red: 1.00, green: 0.69, blue: 0.39) // Tangerine
        case "7": return Color(red: 0.52, green: 0.81, blue: 0.92) // Peacock
        case "8": return Color(red: 0.62, green: 0.62, blue: 0.62) // Graphite
        case "9": return Color(red: 0.42, green: 0.66, blue: 0.98) // Blueberry
        case "10": return Color(red: 0.33, green: 0.83, blue: 0.46) // Basil
        case "11": return Color(red: 0.89, green: 0.25, blue: 0.21) // Tomato
        default: return .blue
        }
    }
}
