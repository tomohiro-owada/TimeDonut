import Foundation

struct AuthState: Codable {
    // MARK: - Properties
    var isAuthenticated: Bool
    var userEmail: String?
    var userName: String?
    var userPhotoURL: URL?
    var tokenExpirationDate: Date?

    // MARK: - Computed Properties
    var isTokenExpired: Bool {
        guard let expirationDate = tokenExpirationDate else { return true }
        return Date() >= expirationDate
    }
}
