//
//  AppStateViewModel.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import Foundation

/// Main application state manager that handles authentication and user session
/// This ViewModel manages the authentication lifecycle and provides auth state to views
@MainActor
final class AppStateViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Current authentication state containing user information and session status
    @Published var authState: AuthState

    /// Indicates whether an authentication operation is in progress
    @Published var isLoading: Bool = false

    /// Error message to display to the user when authentication fails
    @Published var errorMessage: String? = nil

    /// Controls the visibility of the sign-in view
    @Published var showSignIn: Bool = false

    // MARK: - Dependencies

    private let authManager: GoogleAuthManager
    private let keychainManager: KeychainManager

    // MARK: - Initialization

    /// Initializes the AppStateViewModel with required dependencies
    /// - Parameters:
    ///   - authManager: The Google authentication manager (default: shared instance)
    ///   - keychainManager: The keychain manager for secure storage (default: shared instance)
    init(
        authManager: GoogleAuthManager = .shared,
        keychainManager: KeychainManager = .shared
    ) {
        self.authManager = authManager
        self.keychainManager = keychainManager
        self.authState = AuthState(isAuthenticated: false)

        // Check authentication state on initialization
        Task {
            await checkAuthState()
        }
    }

    // MARK: - Public Methods

    /// Checks the current authentication state by attempting to restore previous sign-in
    /// This method is called on app launch to verify if the user has a valid session
    func checkAuthState() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let isAuthenticated = try await authManager.restorePreviousSignIn()

            if isAuthenticated {
                // Successfully restored session - update auth state with user info
                authState.isAuthenticated = true
                authState.userEmail = authManager.currentUser?.email
                authState.userName = authManager.currentUser?.email // Use email as name
                authState.userPhotoURL = nil // Photo URL not available in custom OAuth

                // Set token expiration date
                if let expiresAt = authManager.currentUser?.expiresAt {
                    authState.tokenExpirationDate = expiresAt
                }
            } else {
                // No previous sign-in found - show sign-in view
                showSignIn = true
            }
        } catch {
            // Error occurred during restoration - show sign-in view and display error
            errorMessage = error.localizedDescription
            showSignIn = true
        }
    }

    /// Initiates the Google Sign-In flow
    /// Presents the authentication window and handles the OAuth flow
    func signIn() async {
        NSLog("🔑 AppStateViewModel: signIn() called")
        isLoading = true
        defer { isLoading = false }

        do {
            NSLog("📞 AppStateViewModel: Calling authManager.signIn()")
            try await authManager.signIn()

            NSLog("✅ AppStateViewModel: Sign-in successful, updating state")
            // Successfully signed in - update auth state
            authState.isAuthenticated = true
            authState.userEmail = authManager.currentUser?.email
            authState.userName = authManager.currentUser?.email // Use email as name
            authState.userPhotoURL = nil // Photo URL not available in custom OAuth

            // Set token expiration date
            if let expiresAt = authManager.currentUser?.expiresAt {
                authState.tokenExpirationDate = expiresAt
            }

            // Hide sign-in view and clear any error messages
            showSignIn = false
            errorMessage = nil
            NSLog("✅ AppStateViewModel: Auth state updated successfully")
        } catch {
            // Sign-in failed - display error message
            NSLog("❌ AppStateViewModel: Sign-in failed: \(error.localizedDescription)")
            errorMessage = "サインインに失敗しました: \(error.localizedDescription)"
        }
    }

    /// Signs out the current user and clears all stored credentials
    /// This removes the user from GoogleSignIn and deletes all tokens from the Keychain
    func signOut() {
        authManager.signOut()
        authState = AuthState(isAuthenticated: false)
        showSignIn = true
        errorMessage = nil
    }
}
