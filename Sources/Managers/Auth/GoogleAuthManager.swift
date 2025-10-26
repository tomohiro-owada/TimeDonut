//
//  GoogleAuthManager.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import Foundation
import AppKit
import Network

/// Manages Google OAuth 2.0 authentication using custom OAuth flow
/// This manager handles sign-in, sign-out, token management, and session restoration
@MainActor
final class GoogleAuthManager: ObservableObject {
    // MARK: - Singleton
    static let shared = GoogleAuthManager()

    // MARK: - Published Properties
    @Published var currentUser: GoogleUser?

    // MARK: - Private Properties
    private let keychainManager = KeychainManager.shared
    private var localServer: NWListener?
    private var serverContinuation: CheckedContinuation<String, Error>?

    // MARK: - Configuration
    private let clientID = Constants.Google.clientID
    private let clientSecret = Constants.Google.clientSecret
    private let scopes = [Constants.Google.calendarScope]
    private let redirectURI = "http://localhost:8080/oauth2callback"
    private let authorizationEndpoint = "https://accounts.google.com/o/oauth2/auth"
    private let tokenEndpoint = "https://oauth2.googleapis.com/token"

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// Attempts to restore a previously signed-in user session
    /// This method tries to restore the user from the Keychain
    /// - Returns: True if a valid session was restored, false otherwise
    /// - Throws: AuthError if restoration fails
    func restorePreviousSignIn() async throws -> Bool {
        NSLog("🔐 GoogleAuthManager: Attempting to restore previous sign-in")

        // Try to load tokens from Keychain
        guard let accessToken = try keychainManager.retrieve(for: .accessToken),
              let refreshToken = try keychainManager.retrieve(for: .refreshToken) else {
            NSLog("ℹ️ GoogleAuthManager: No stored tokens found")
            return false
        }

        let email = try? keychainManager.retrieve(for: .userEmail)

        // Create user object from stored tokens
        let user = GoogleUser(
            email: email,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date() // Will be refreshed on first use
        )

        currentUser = user
        NSLog("✅ GoogleAuthManager: Previous sign-in restored for \(email ?? "unknown user")")

        // Validate tokens by attempting to refresh
        do {
            try await refreshAccessTokenIfNeeded()
            return true
        } catch {
            NSLog("❌ GoogleAuthManager: Token validation failed: \(error)")
            currentUser = nil
            keychainManager.deleteAll()
            return false
        }
    }

    /// Initiates the Google Sign-In flow using custom OAuth 2.0
    /// Opens browser for authentication and receives the callback via local server
    /// - Throws: AuthError if authentication fails
    func signIn() async throws {
        NSLog("🔐 GoogleAuthManager: signIn() called")

        // Step 1: Start local HTTP server to receive the callback
        let authorizationCode = try await startLocalServerAndGetCode()

        // Step 2: Exchange authorization code for tokens
        try await exchangeCodeForTokens(authorizationCode)

        NSLog("✅ GoogleAuthManager: Sign-in successful")
    }

    /// Signs out the current user and clears all stored credentials
    /// This removes tokens from the Keychain and clears the current user
    func signOut() {
        NSLog("🔐 GoogleAuthManager: Signing out")
        currentUser = nil
        keychainManager.deleteAll()
        NSLog("✅ GoogleAuthManager: Sign-out complete")
    }

    /// Refreshes the access token if it has expired or is about to expire
    /// This method checks the token expiration and refreshes if needed
    /// - Throws: AuthError.notAuthenticated if no user is signed in, or token refresh errors
    func refreshAccessTokenIfNeeded() async throws {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }

        let now = Date()
        let fiveMinutesFromNow = now.addingTimeInterval(300)

        // Check if token is expired or about to expire (within 5 minutes)
        if user.expiresAt <= fiveMinutesFromNow {
            NSLog("🔄 GoogleAuthManager: Access token expired or about to expire, refreshing...")
            try await refreshAccessToken()
        }
    }

    // MARK: - Private Methods

    /// Starts a local HTTP server and opens the OAuth URL in the browser
    /// - Returns: The authorization code received from the callback
    /// - Throws: AuthError if the server fails to start or no code is received
    private func startLocalServerAndGetCode() async throws -> String {
        // Start local server on port 8080
        try await startLocalServer()

        // Build OAuth URL
        let state = UUID().uuidString
        var components = URLComponents(string: authorizationEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "prompt", value: "consent") // Force consent to get refresh token
        ]

        guard let url = components.url else {
            stopLocalServer()
            throw AuthError.notAuthenticated
        }

        NSLog("🌐 GoogleAuthManager: Opening OAuth URL in browser")
        NSWorkspace.shared.open(url)

        // Wait for the callback with the authorization code
        do {
            let code = try await waitForAuthorizationCode()
            stopLocalServer()
            return code
        } catch {
            stopLocalServer()
            throw error
        }
    }

    /// Starts a local HTTP server on port 8080 to receive OAuth callbacks
    /// - Throws: AuthError if the server fails to start
    private func startLocalServer() async throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        let listener = try NWListener(using: parameters, on: 8080)

        listener.newConnectionHandler = { [weak self] connection in
            Task { @MainActor in
                await self?.handleConnection(connection)
            }
        }

        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                NSLog("✅ Local server started on port 8080")
            case .failed(let error):
                NSLog("❌ Local server failed: \(error)")
            case .cancelled:
                NSLog("🛑 Local server cancelled")
            default:
                break
            }
        }

        listener.start(queue: .main)
        localServer = listener
    }

    /// Stops the local HTTP server
    private func stopLocalServer() {
        localServer?.cancel()
        localServer = nil
        NSLog("🛑 Local server stopped")
    }

    /// Handles incoming HTTP connections from the OAuth callback
    /// - Parameter connection: The network connection to handle
    private func handleConnection(_ connection: NWConnection) async {
        connection.start(queue: .main)

        // Read the HTTP request
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self, let data = data else { return }

            let request = String(data: data, encoding: .utf8) ?? ""
            NSLog("📨 Received HTTP request")

            // Extract authorization code from the request
            if let code = self.extractAuthorizationCode(from: request) {
                NSLog("✅ Authorization code received")

                // Send success response
                let response = """
                HTTP/1.1 200 OK\r
                Content-Type: text/html\r
                \r
                <html>
                <head><title>TimeDonut - Sign In</title></head>
                <body style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding: 50px;">
                <h1>✅ Sign in successful!</h1>
                <p>You can close this window and return to TimeDonut.</p>
                <script>window.close();</script>
                </body>
                </html>
                """

                connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })

                // Resume the continuation with the code
                Task { @MainActor in
                    self.serverContinuation?.resume(returning: code)
                    self.serverContinuation = nil
                }
            } else {
                // Send error response
                let response = """
                HTTP/1.1 400 Bad Request\r
                Content-Type: text/html\r
                \r
                <html>
                <head><title>TimeDonut - Sign In Error</title></head>
                <body style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding: 50px;">
                <h1>❌ Sign in failed</h1>
                <p>No authorization code received. Please try again.</p>
                </body>
                </html>
                """

                connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })

                Task { @MainActor in
                    self.serverContinuation?.resume(throwing: AuthError.notAuthenticated)
                    self.serverContinuation = nil
                }
            }
        }
    }

    /// Extracts the authorization code from the HTTP request
    /// - Parameter request: The HTTP request string
    /// - Returns: The authorization code if found
    private func extractAuthorizationCode(from request: String) -> String? {
        // Parse the request line to get the path and query
        guard let firstLine = request.components(separatedBy: "\r\n").first else {
            return nil
        }

        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            return nil
        }

        let path = parts[1]

        // Extract query parameters
        guard let urlComponents = URLComponents(string: "http://localhost\(path)") else {
            return nil
        }

        return urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
    }

    /// Waits for the authorization code to be received from the OAuth callback
    /// - Returns: The authorization code
    /// - Throws: AuthError if no code is received within timeout
    private func waitForAuthorizationCode() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            serverContinuation = continuation

            // Set a timeout of 5 minutes
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000_000) // 5 minutes
                if serverContinuation != nil {
                    serverContinuation?.resume(throwing: AuthError.notAuthenticated)
                    serverContinuation = nil
                }
            }
        }
    }

    /// Exchanges the authorization code for access and refresh tokens
    /// - Parameter code: The authorization code received from OAuth callback
    /// - Throws: AuthError if the exchange fails
    private func exchangeCodeForTokens(_ code: String) async throws {
        NSLog("🔄 GoogleAuthManager: Exchanging authorization code for tokens")

        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = [
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code"
        ]

        let bodyString = bodyParams.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.notAuthenticated
        }

        guard httpResponse.statusCode == 200 else {
            NSLog("❌ Token exchange failed with status code: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                NSLog("❌ Error response: \(errorString)")
            }
            throw AuthError.notAuthenticated
        }

        // Parse the response
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        // Calculate expiration date
        let expiresAt = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))

        // Create user object
        let user = GoogleUser(
            email: nil, // We'll need to fetch this separately if needed
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresAt: expiresAt
        )

        currentUser = user

        // Save tokens to Keychain
        try keychainManager.save(token: tokenResponse.accessToken, for: .accessToken)
        try keychainManager.save(token: tokenResponse.refreshToken, for: .refreshToken)

        NSLog("✅ Tokens saved to Keychain")

        // Fetch user email from Google's userinfo endpoint
        try await fetchUserEmail()
    }

    /// Fetches the user's email from Google's userinfo endpoint
    /// - Throws: Error if the request fails
    private func fetchUserEmail() async throws {
        guard let user = currentUser else { return }

        var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!)
        request.setValue("Bearer \(user.accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let email = json["email"] as? String {
            currentUser?.email = email
            try? keychainManager.save(token: email, for: .userEmail)
            NSLog("✅ User email: \(email)")
        }
    }

    /// Refreshes the access token using the refresh token
    /// - Throws: AuthError if no user is signed in or refresh fails
    private func refreshAccessToken() async throws {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }

        NSLog("🔄 GoogleAuthManager: Refreshing access token")

        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "refresh_token": user.refreshToken,
            "grant_type": "refresh_token"
        ]

        let bodyString = bodyParams.map { key, value in
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.notAuthenticated
        }

        guard httpResponse.statusCode == 200 else {
            NSLog("❌ Token refresh failed with status code: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                NSLog("❌ Error response: \(errorString)")
            }
            throw AuthError.notAuthenticated
        }

        // Parse the response
        let tokenResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)

        // Calculate expiration date
        let expiresAt = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))

        // Update user with new access token
        currentUser?.accessToken = tokenResponse.accessToken
        currentUser?.expiresAt = expiresAt

        // Save new access token to Keychain
        try keychainManager.save(token: tokenResponse.accessToken, for: .accessToken)

        NSLog("✅ Access token refreshed successfully")
    }
}

// MARK: - Supporting Types

/// Represents a Google user with OAuth tokens
struct GoogleUser {
    var email: String?
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date
}

/// Response structure for token exchange
private struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

/// Response structure for token refresh
private struct RefreshTokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}
