//
//  GoogleAuthManager.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import Foundation
import AppKit
import Network

/// Manages Google OAuth 2.0 authentication using Cloud Functions
/// This manager handles sign-in, sign-out, and user ID management
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
    private let redirectURI = Constants.Google.redirectURI
    private let authURL = Constants.CloudFunctions.authURL

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// Attempts to restore a previously signed-in user session
    /// This method tries to restore the user from the Keychain
    /// - Returns: True if a valid session was restored, false otherwise
    /// - Throws: AuthError if restoration fails
    func restorePreviousSignIn() async throws -> Bool {
        NSLog("🔐 GoogleAuthManager: Attempting to restore previous sign-in")

        // Try to load user ID from Keychain
        guard let userID = try keychainManager.retrieve(for: .userID) else {
            NSLog("ℹ️ GoogleAuthManager: No stored user ID found")
            return false
        }

        let email = try? keychainManager.retrieve(for: .userEmail)

        // Create user object from stored user ID
        let user = GoogleUser(
            userID: userID,
            email: email
        )

        currentUser = user
        NSLog("✅ GoogleAuthManager: Previous sign-in restored for \(email ?? "user ID: \(userID)")")

        return true
    }

    /// Initiates the Google Sign-In flow using Cloud Functions
    /// Opens browser for authentication and receives the user ID via local server
    /// - Throws: AuthError if authentication fails
    func signIn() async throws {
        NSLog("🔐 GoogleAuthManager: signIn() called")

        // Step 1: Start local HTTP server to receive the callback
        let userID = try await startLocalServerAndGetUserID()

        // Step 2: Save user ID to Keychain
        try keychainManager.save(token: userID, for: .userID)

        // Step 3: Create user object
        currentUser = GoogleUser(
            userID: userID,
            email: nil
        )

        NSLog("✅ GoogleAuthManager: Sign-in successful, user ID: \(userID)")
    }

    /// Signs out the current user and clears all stored credentials
    /// This removes the user ID from the Keychain and clears the current user
    func signOut() {
        NSLog("🔐 GoogleAuthManager: Signing out")
        currentUser = nil
        keychainManager.deleteAll()
        NSLog("✅ GoogleAuthManager: Sign-out complete")
    }

    // MARK: - Private Methods

    /// Starts a local HTTP server and opens the Cloud Functions auth URL in the browser
    /// - Returns: The user ID received from the callback
    /// - Throws: AuthError if the server fails to start or no user ID is received
    private func startLocalServerAndGetUserID() async throws -> String {
        // Start local server on port 8080
        try await startLocalServer()

        // Build Cloud Functions auth URL
        let state = UUID().uuidString
        var components = URLComponents(string: authURL)!
        components.queryItems = [
            URLQueryItem(name: "state", value: state)
        ]

        guard let url = components.url else {
            stopLocalServer()
            throw AuthError.notAuthenticated
        }

        NSLog("🌐 GoogleAuthManager: Opening Cloud Functions auth URL in browser")
        NSWorkspace.shared.open(url)

        // Wait for the callback with the user ID
        do {
            let userID = try await waitForUserID()
            stopLocalServer()
            return userID
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

            // Extract user ID from the request
            if let userID = self.extractUserID(from: request) {
                NSLog("✅ User ID received: \(userID)")

                // Send success response
                let response = """
                HTTP/1.1 200 OK\r
                Content-Type: text/html\r
                \r
                <html>
                <head>
                    <meta charset="UTF-8">
                    <title>TimeDonut - 認証完了</title>
                    <style>
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                            text-align: center;
                            padding: 50px;
                            background: #f5f5f5;
                        }
                        .container {
                            background: white;
                            padding: 40px;
                            border-radius: 12px;
                            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                            max-width: 400px;
                            margin: 0 auto;
                        }
                        h1 { color: #4CAF50; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1>✅ 認証成功！</h1>
                        <p>TimeDonutアプリに戻ってください。</p>
                        <p>このウィンドウは閉じても構いません。</p>
                    </div>
                    <script>setTimeout(() => window.close(), 3000);</script>
                </body>
                </html>
                """

                connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })

                // Resume the continuation with the user ID
                Task { @MainActor in
                    self.serverContinuation?.resume(returning: userID)
                    self.serverContinuation = nil
                }
            } else {
                // Send error response
                let response = """
                HTTP/1.1 400 Bad Request\r
                Content-Type: text/html\r
                \r
                <html>
                <head>
                    <meta charset="UTF-8">
                    <title>TimeDonut - 認証エラー</title>
                </head>
                <body style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding: 50px;">
                <h1>❌ 認証失敗</h1>
                <p>ユーザーIDを受信できませんでした。もう一度お試しください。</p>
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

    /// Extracts the user ID from the HTTP request
    /// - Parameter request: The HTTP request string
    /// - Returns: The user ID if found
    private func extractUserID(from request: String) -> String? {
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

        return urlComponents.queryItems?.first(where: { $0.name == "user_id" })?.value
    }

    /// Waits for the user ID to be received from the OAuth callback
    /// - Returns: The user ID
    /// - Throws: AuthError if no user ID is received within timeout
    private func waitForUserID() async throws -> String {
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
}

// MARK: - Supporting Types

/// Represents a Google user with user ID
struct GoogleUser {
    let userID: String
    var email: String?
}
