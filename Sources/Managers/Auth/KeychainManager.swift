import Foundation
import Security

/// Thread-safe manager for secure storage of OAuth tokens and user credentials in the Keychain
final class KeychainManager {
    // MARK: - Singleton
    static let shared = KeychainManager()

    // MARK: - Private Properties
    private let queue = DispatchQueue(label: "com.timedonut.keychain", attributes: .concurrent)

    // MARK: - Initialization
    private init() {}

    // MARK: - Token Types
    enum TokenType: String, CaseIterable {
        case accessToken
        case refreshToken
        case userEmail

        var rawValue: String {
            switch self {
            case .accessToken:
                return Constants.Keychain.accessTokenKey
            case .refreshToken:
                return Constants.Keychain.refreshTokenKey
            case .userEmail:
                return Constants.Keychain.userEmailKey
            }
        }
    }

    // MARK: - Public Methods

    /// Saves a token to the Keychain
    /// - Parameters:
    ///   - token: The token string to save
    ///   - type: The type of token being saved
    /// - Throws: KeychainError if the save operation fails
    func save(token: String, for type: TokenType) throws {
        try queue.sync(flags: .barrier) {
            guard let data = token.data(using: .utf8) else {
                throw KeychainError.saveFailed(errSecParam)
            }

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: type.rawValue,
                kSecAttrService as String: Constants.Keychain.serviceName,
                kSecValueData as String: data
            ]

            // Delete existing item if it exists
            SecItemDelete(query as CFDictionary)

            // Add new item
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw KeychainError.saveFailed(status)
            }
        }
    }

    /// Retrieves a token from the Keychain
    /// - Parameter type: The type of token to retrieve
    /// - Returns: The token string if found, nil if not found
    /// - Throws: KeychainError if the retrieval operation fails (excluding item not found)
    func retrieve(for type: TokenType) throws -> String? {
        try queue.sync {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: type.rawValue,
                kSecAttrService as String: Constants.Keychain.serviceName,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            guard status == errSecSuccess else {
                if status == errSecItemNotFound {
                    return nil
                }
                throw KeychainError.retrieveFailed(status)
            }

            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                return nil
            }

            return token
        }
    }

    /// Deletes a token from the Keychain
    /// - Parameter type: The type of token to delete
    func delete(for type: TokenType) {
        queue.sync(flags: .barrier) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: type.rawValue,
                kSecAttrService as String: Constants.Keychain.serviceName
            ]

            SecItemDelete(query as CFDictionary)
        }
    }

    /// Deletes all tokens from the Keychain
    func deleteAll() {
        TokenType.allCases.forEach { delete(for: $0) }
    }
}

// MARK: - Keychain Errors

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
}

extension KeychainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to Keychain (status: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve from Keychain (status: \(status))"
        }
    }
}
