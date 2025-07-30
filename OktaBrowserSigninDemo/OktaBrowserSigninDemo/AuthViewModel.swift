import Foundation
import Observation
import BrowserSignin

@Observable
final class AuthViewModel {
    // MARK: - Dependencies
    
    /// This is the service that handles all the sign-in, sign-out, token, and user info logic.
    private let authService: AuthServiceProtocol

    // MARK: - UI State Properties

    /// True if the user is currently logged in.
    var isAuthenticated: Bool = false
    
    /// The user's ID token (used for secure backend communication).
    var idToken: String?
    
    /// Shows a loading spinner while something is happening in the background.
    var isLoading: Bool = false
    
    /// If something goes wrong (e.g., login fails), the error message will show in the UI.
    var errorMessage: String?
    
    /// This holds a message returned from the resources server.
    var serverMessage: String?
    
    // MARK: - Initialization

    /// Create the view model and immediately update the UI with the current authentication status.
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        updateUI()
    }
    
    // MARK: - UI State Management

    /// Updates the `isAuthenticated` and `idToken` values from the authentication service.
    func updateUI() {
        isAuthenticated = authService.isAuthenticated
        idToken = authService.idToken
    }
    
    // MARK: - Authentication
    
    /// Called when the user taps the "Sign In" or "Sign Out" button.
    /// Signs the user in or out, updates the UI, and handles any errors.
    @MainActor
    func handleAuthAction() async {
        setLoading(true)
        defer { setLoading(false) }

        do {
            if isAuthenticated {
                // User is signed in → sign them out
                try await authService.signOut()
            } else {
                // User is signed out → sign them in
                try await authService.signIn()
            }
            updateUI()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Token Handling
    
    /// Refreshes the user's token if it's about to expire.
    /// Keeps the user logged in longer without needing to manually sign in again.
    @MainActor
    func refreshToken() async {
        setLoading(true)
        defer { setLoading(false) }

        do {
            try await authService.refreshTokenIfNeeded()
            updateUI()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - User Info
    
    /// Requests user information (like name, email, etc.) from the authentication service.
    /// Returns a dictionary of user data or nil if it fails.
    @MainActor
    func fetchUserInfo() async -> UserInfo? {
        do {
            let userInfo = try await authService.userInfo()
            return userInfo
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Token Info

    /// Retrieves token metadata like expiry time or claims.
    /// Returns nil if no token is available.
    func fetchTokenInfo() -> TokenInfo? {
        guard let tokenInfo = authService.tokenInfo() else { return nil }
        return tokenInfo
    }
    
    // MARK: - Server Messages

    /// Asks the backend for a message and saves it for display in the UI.
    @MainActor
    func fetchMessage() async {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            let message = try await authService.fetchMessageFromBackend()
            serverMessage = message
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers
    
    /// Sets the loading state (used to show/hide a spinner in the UI).
    private func setLoading(_ value: Bool) {
        isLoading = value
    }
}
