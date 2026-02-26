import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class AuthService {
    static let shared = AuthService()
    private var currentNonce: String?

    private init() {}

    var currentUser: User? {
        Auth.auth().currentUser
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Email/Password

    func signUp(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }

    func signIn(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    // MARK: - Apple Sign-In

    func prepareAppleSignIn() -> (ASAuthorizationAppleIDRequest) -> Void {
        let nonce = randomNonceString()
        currentNonce = nonce

        return { request in
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
        }
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async throws -> User {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw AuthError.invalidCredential
            }

            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            return authResult.user

        case .failure(let error):
            throw error
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Auth State Listener

    func addStateListener(_ callback: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            callback(user)
        }
    }

    func removeStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}

// MARK: - Helpers

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
    }
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    return String(randomBytes.map { charset[Int($0) % charset.count] })
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}

// MARK: - Error

enum AuthError: LocalizedError {
    case invalidCredential
    case noCurrentUser

    var errorDescription: String? {
        switch self {
        case .invalidCredential: return "Invalid Apple Sign-In credential."
        case .noCurrentUser: return "No user is currently signed in."
        }
    }
}
