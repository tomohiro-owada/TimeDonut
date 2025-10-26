//
//  Errors.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import Foundation

// MARK: - Recovery Option

/// Represents a recovery option for an error
struct RecoveryOption {
    let title: String
    let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

// MARK: - AppError Protocol

/// Base protocol for application errors
protocol AppError: LocalizedError {
    var title: String { get }
    var message: String { get }
    var recoveryOptions: [RecoveryOption] { get }
}

extension AppError {
    var errorDescription: String? {
        message
    }

    var failureReason: String? {
        title
    }
}

// MARK: - Authentication Errors

enum AuthError: AppError {
    case noWindow
    case notAuthenticated

    var title: String {
        switch self {
        case .noWindow:
            return "Window Not Available"
        case .notAuthenticated:
            return "Not Authenticated"
        }
    }

    var message: String {
        switch self {
        case .noWindow:
            return "Unable to present authentication window. Please try again."
        case .notAuthenticated:
            return "You need to sign in to access this feature. Please authenticate with your Google account."
        }
    }

    var recoveryOptions: [RecoveryOption] {
        switch self {
        case .noWindow:
            return []
        case .notAuthenticated:
            return []
        }
    }
}

// MARK: - Calendar Errors

enum CalendarError: AppError {
    case notAuthenticated
    case networkError
    case apiError(String)

    var title: String {
        switch self {
        case .notAuthenticated:
            return "Authentication Required"
        case .networkError:
            return "Network Error"
        case .apiError:
            return "Calendar API Error"
        }
    }

    var message: String {
        switch self {
        case .notAuthenticated:
            return "Please sign in to access your calendar events."
        case .networkError:
            return "Unable to connect to Google Calendar. Please check your internet connection and try again."
        case .apiError(let details):
            return "Failed to fetch calendar data: \(details)"
        }
    }

    var recoveryOptions: [RecoveryOption] {
        switch self {
        case .notAuthenticated:
            return []
        case .networkError:
            return []
        case .apiError:
            return []
        }
    }
}

// MARK: - Network Errors

enum NetworkError: AppError {
    case noConnection
    case timeout
    case serverError(Int)

    var title: String {
        switch self {
        case .noConnection:
            return "No Internet Connection"
        case .timeout:
            return "Request Timeout"
        case .serverError:
            return "Server Error"
        }
    }

    var message: String {
        switch self {
        case .noConnection:
            return "Unable to connect to the internet. Please check your network settings."
        case .timeout:
            return "The request took too long to complete. Please try again."
        case .serverError(let statusCode):
            return "Server returned an error (Status code: \(statusCode)). Please try again later."
        }
    }

    var recoveryOptions: [RecoveryOption] {
        switch self {
        case .noConnection:
            return []
        case .timeout:
            return []
        case .serverError:
            return []
        }
    }
}
