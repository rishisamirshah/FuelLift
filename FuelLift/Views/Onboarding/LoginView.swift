import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.orange.gradient)

                    Text("FuelLift")
                        .font(.largeTitle.bold())

                    Text("Track fuel. Crush lifts. Level up.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 16) {
                    // Apple Sign-In
                    SignInWithAppleButton(.signIn) { request in
                        authViewModel.getAppleSignInRequest()(request)
                    } onCompletion: { result in
                        Task {
                            await authViewModel.handleAppleSignIn(result: result)
                        }
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(.quaternary)
                        Text("or").font(.caption).foregroundStyle(.secondary)
                        Rectangle().frame(height: 1).foregroundStyle(.quaternary)
                    }

                    // Email fields
                    VStack(spacing: 12) {
                        TextField("Email", text: $authViewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $authViewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(authViewModel.isSignUpMode ? .newPassword : .password)
                    }

                    Button {
                        Task { await authViewModel.signInWithEmail() }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(authViewModel.isSignUpMode ? "Create Account" : "Sign In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(authViewModel.isLoading)

                    HStack {
                        Button(authViewModel.isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                            withAnimation { authViewModel.isSignUpMode.toggle() }
                        }
                        .font(.footnote)
                        .foregroundStyle(.orange)

                        Spacer()

                        if !authViewModel.isSignUpMode {
                            Button("Forgot Password?") {
                                Task { await authViewModel.resetPassword() }
                            }
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .alert("Notice", isPresented: $authViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
        }
    }
}
