import SwiftUI
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var needsOnboarding = false
    @Published var errorMessage: String?
    @Published var showError = false

    // Login form
    @Published var email = ""
    @Published var password = ""
    @Published var isSignUpMode = false

    init() {
        // Firebase disabled — skip straight to authenticated state for local dev
        isAuthenticated = true
        needsOnboarding = false
        isLoading = false
    }

    // MARK: - Email Auth (no-op without Firebase)

    func signInWithEmail() async {
        isAuthenticated = true
    }

    // MARK: - Apple Sign-In (no-op without Firebase)

    func getAppleSignInRequest() -> (ASAuthorizationAppleIDRequest) -> Void {
        return { _ in }
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isAuthenticated = true
    }

    // MARK: - Sign Out

    func signOut() {
        isAuthenticated = false
    }

    // MARK: - Password Reset

    func resetPassword() async {
        showErrorMessage("Firebase not configured — password reset unavailable.")
    }

    // MARK: - Helpers

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
