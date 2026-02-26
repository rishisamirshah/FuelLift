import SwiftUI
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var needsOnboarding = false
    @Published var errorMessage: String?
    @Published var showError = false

    // Login form
    @Published var email = ""
    @Published var password = ""
    @Published var isSignUpMode = false

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        listenForAuthChanges()
    }

    deinit {
        if let listener = authListener {
            AuthService.shared.removeStateListener(listener)
        }
    }

    // MARK: - Auth State

    private func listenForAuthChanges() {
        authListener = AuthService.shared.addStateListener { [weak self] user in
            Task { @MainActor in
                self?.isAuthenticated = user != nil
                self?.isLoading = false
                if let user {
                    await self?.checkOnboardingStatus(userId: user.uid)
                }
            }
        }
    }

    private func checkOnboardingStatus(userId: String) async {
        do {
            let profile = try await FirestoreService.shared.fetchUserProfile(userId: userId)
            needsOnboarding = !(profile?["hasCompletedOnboarding"] as? Bool ?? false)
        } catch {
            needsOnboarding = true
        }
    }

    // MARK: - Email Auth

    func signInWithEmail() async {
        guard !email.isEmpty, !password.isEmpty else {
            showErrorMessage("Please enter email and password.")
            return
        }

        isLoading = true
        do {
            if isSignUpMode {
                _ = try await AuthService.shared.signUp(email: email, password: password)
            } else {
                _ = try await AuthService.shared.signIn(email: email, password: password)
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Apple Sign-In

    func getAppleSignInRequest() -> (ASAuthorizationAppleIDRequest) -> Void {
        return AuthService.shared.prepareAppleSignIn()
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        do {
            _ = try await AuthService.shared.handleAppleSignIn(result: result)
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try AuthService.shared.signOut()
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }

    // MARK: - Password Reset

    func resetPassword() async {
        guard !email.isEmpty else {
            showErrorMessage("Please enter your email.")
            return
        }
        do {
            try await AuthService.shared.resetPassword(email: email)
            showErrorMessage("Password reset email sent.")
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// Required for Apple Sign-In — forward declare to avoid import loop
import AuthenticationServices
typealias ASAuthorizationAppleIDRequest = AuthenticationServices.ASAuthorizationAppleIDRequest
