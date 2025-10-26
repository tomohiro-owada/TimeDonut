//
//  Date+Extensions.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import Foundation

extension Date {
    // MARK: - Formatting

    /// Returns ISO8601 formatted string
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }

    /// Returns ISO8601 formatted string with fractional seconds
    var iso8601StringWithFractionalSeconds: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }

    /// Formats date as time string (e.g., "2:30 PM")
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Formats date as short date string (e.g., "10/26/25")
    func shortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    /// Formats date as medium date string (e.g., "Oct 26, 2025")
    func mediumDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    /// Formats date and time (e.g., "Oct 26, 2025 at 2:30 PM")
    func dateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Formats date with custom format
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    // MARK: - Time Calculations

    /// Returns start of day (midnight)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns end of day (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Returns start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Returns end of week
    var endOfWeek: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfWeek) ?? self
    }

    /// Returns start of month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Returns end of month
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }

    /// Adds specified number of days
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Adds specified number of hours
    func addingHours(_ hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    /// Adds specified number of minutes
    func addingMinutes(_ minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    /// Returns time interval until another date in minutes
    func minutesUntil(_ date: Date) -> Int {
        let interval = date.timeIntervalSince(self)
        return Int(interval / 60)
    }

    /// Returns time interval until another date in hours
    func hoursUntil(_ date: Date) -> Double {
        let interval = date.timeIntervalSince(self)
        return interval / 3600
    }

    /// Checks if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Checks if date is in the past
    var isPast: Bool {
        self < Date()
    }

    /// Checks if date is in the future
    var isFuture: Bool {
        self > Date()
    }

    /// Checks if date is within a specific date range
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        self >= startDate && self <= endDate
    }

    // MARK: - Static Factory Methods

    /// Creates date from ISO8601 string
    static func fromISO8601String(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: string) {
            return date
        }
        // Try with fractional seconds
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
}
