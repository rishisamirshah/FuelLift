import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingHuge) {
                Spacer()

                // Logo
                VStack(spacing: Theme.spacingMD) {
                    Image("logo_fuellift")
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)

                    Text("FuelLift")
                        .font(.system(size: Theme.titleSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Track fuel. Crush lifts. Level up.")
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                VStack(spacing: Theme.spacingLG) {
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
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))

                    // Divider
                    HStack(spacing: Theme.spacingSM) {
                        Rectangle().frame(height: 1).foregroundStyle(Color.appTextTertiary.opacity(0.3))
                        Text("or")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextTertiary)
                        Rectangle().frame(height: 1).foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }

                    // Email fields
                    VStack(spacing: Theme.spacingMD) {
                        TextField("Email", text: $authViewModel.email)
                            .padding(Theme.spacingMD)
                            .background(Color.appCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .foregroundStyle(Color.appTextPrimary)

                        SecureField("Password", text: $authViewModel.password)
                            .padding(Theme.spacingMD)
                            .background(Color.appCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                            .textContentType(authViewModel.isSignUpMode ? .newPassword : .password)
                            .foregroundStyle(Color.appTextPrimary)
                    }

                    Button {
                        Task { await authViewModel.signInWithEmail() }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingMD)
                        } else {
                            Text(authViewModel.isSignUpMode ? "Create Account" : "Sign In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingMD)
                        }
                    }
                    .background(Color.appAccent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                    .disabled(authViewModel.isLoading)

                    HStack {
                        Button(authViewModel.isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                            withAnimation { authViewModel.isSignUpMode.toggle() }
                        }
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appAccent)

                        Spacer()

                        if !authViewModel.isSignUpMode {
                            Button("Forgot Password?") {
                                Task { await authViewModel.resetPassword() }
                            }
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, Theme.spacingXXL)
                .padding(.bottom, 40)
            }
            .screenBackground()
            .alert("Notice", isPresented: $authViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
        }
    }
}
