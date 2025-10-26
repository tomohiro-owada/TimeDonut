import Foundation

struct UserProfile: Codable {
    // MARK: - Properties
    let email: String
    let name: String
    let photoURL: URL?
}
