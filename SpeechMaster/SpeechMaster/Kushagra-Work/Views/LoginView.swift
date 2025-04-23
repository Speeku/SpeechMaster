import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false
    @FocusState private var focusedField: FocusField?
    
    // State variables for navigation
    @State private var navigateToSignUp = false
    @State private var navigateToForgotPassword = false
    
    enum FocusField: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - lighter, more professional shade
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.9, green: 0.93, blue: 0.98)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App logo and title
                        logoView
                            .padding(.top, 50)
                        
                        // Welcome text
                        welcomeTextView
                            .padding(.bottom, 10)
                        
                        // Form fields
                        VStack(spacing: 16) {
                            // Email field
                            FloatingLabelTextField(
                                text: $viewModel.email,
                                placeholderText: "Email",
                                icon: "envelope.fill"
                            )
                            .focused($focusedField, equals: .email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            
                            // Password field
                            FloatingLabelTextField(
                                text: $viewModel.password,
                                placeholderText: "Password",
                                icon: "lock.fill",
                                isSecure: true
                            )
                            .focused($focusedField, equals: .password)
                            .textContentType(.password)
                            .submitLabel(.go)
                            .onSubmit {
                                viewModel.login()
                            }
                            
                            // Forgot password
                            HStack {
                                Spacer()
                                Button(action: {
                                    // Use only the NavigationLink approach for consistency
                                    navigateToForgotPassword = true
                                }) {
                                    Text("Forgot Password?")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, -5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Login button - redesigned with no glow
                        loginButton
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        // Divider with "or" text - reduced spacing
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("or")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5) // Reduced from 10
                        
                        // Social login buttons - reduced spacing from above
                        VStack(spacing: 10) {
                            socialLoginButton(
                                icon: "apple.logo",
                                text: "Sign in with Apple",
                                backgroundColor: colorScheme == .dark ? .white : .black,
                                textColor: colorScheme == .dark ? .black : .white,
                                action: viewModel.signInWithApple
                            )
                            
                            socialLoginButton(
                                icon: "g.circle.fill",
                                text: "Sign in with Google",
                                backgroundColor: Color(red: 0.98, green: 0.98, blue: 0.98),
                                textColor: .black,
                                action: viewModel.signInWithGoogle
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign up option
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            
                            Button(action: {
                                // Use only the NavigationLink approach for consistency
                                navigateToSignUp = true
                            }) {
                                Text("Sign Up")
                                    .fontWeight(.medium)
                                    .font(.footnote)
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal)
                }
                
                // Show error alert if needed
                if viewModel.showError {
                    errorAlert
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    loadingView
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7)) {
                    isAnimating = true
                }
            }
            // Adding direct navigation links
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView(viewModel: SignUpViewModel())
                    .navigationBarBackButtonHidden(false)
                    .onDisappear {
                        // Reset navigation state when view disappears
                        navigateToSignUp = false
                    }
            }
            .navigationDestination(isPresented: $navigateToForgotPassword) {
                ForgotPasswordView()
                    .onDisappear {
                        // Reset navigation state when view disappears
                        navigateToForgotPassword = false
                    }
            }
        }
    }
    
    // MARK: - View Components
    
    private var logoView: some View {
        VStack(spacing: 15) {
            Image("app_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : -20)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
            
            Text("Eloquent")
                .font(.custom("SonsieOne-Regular", size: 32))
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : -10)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
        }
    }
    
    private var welcomeTextView: some View {
        VStack(spacing: 8) {
            Text("Welcome back")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
            
            Text("Sign in to continue your speech journey")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 10)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
    }
    
    private var loginButton: some View {
        Button(action: viewModel.login) {
            HStack {
                Text("Sign In")
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right")
                    .font(.footnote.bold())
                    .padding(.leading, 4)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.2, green: 0.5, blue: 0.9))
            )
        }
        .disabled(viewModel.isLoading || !viewModel.isFormValid)
        .opacity(viewModel.isFormValid ? 1.0 : 0.7)
        .scaleEffect(viewModel.isLoading ? 0.98 : 1.0)
        .animation(.spring(), value: viewModel.isLoading)
    }
    
    private func socialLoginButton(icon: String, text: String, backgroundColor: Color, textColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(width: 22, height: 22)
                
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private var errorAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissError()
                }
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                
                Text("Login Error")
                    .font(.headline)
                
                Text(viewModel.errorMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                
                Button(action: viewModel.dismissError) {
                    Text("OK")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color(red: 0.2, green: 0.5, blue: 0.9))
                        .cornerRadius(10)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            .padding(30)
        }
        .transition(.opacity)
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Signing in...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.7))
            )
        }
        .transition(.opacity)
    }
}

// MARK: - FloatingLabelTextField

struct FloatingLabelTextField: View {
    @Binding var text: String
    let placeholderText: String
    let icon: String
    var isSecure: Bool = false
    
    @State private var isEditing: Bool = false
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(isEditing ? Color(red: 0.2, green: 0.5, blue: 0.9) : .gray)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    if isEditing || !text.isEmpty {
                        Text(placeholderText)
                            .font(.caption)
                            .foregroundColor(isEditing ? Color(red: 0.2, green: 0.5, blue: 0.9) : .gray)
                            .offset(y: 0)
                    }
                    
                    if isSecure {
                        ZStack(alignment: .leading) {
                            if text.isEmpty {
                                Text(isEditing || !text.isEmpty ? "" : placeholderText)
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                            
                            Group {
                                if showPassword {
                                    TextField("", text: $text)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("", text: $text)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                            }
                            .onChange(of: text) { _ in
                                isEditing = true
                            }
                        }
                    } else {
                        TextField(isEditing || !text.isEmpty ? "" : placeholderText, text: $text)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: text) { _ in
                                isEditing = true
                            }
                    }
                }
                
                if isSecure {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .disabled(text.isEmpty) // Disable toggle when text is empty
                    .opacity(text.isEmpty ? 0.5 : 1.0) // Visual indicator that it's disabled
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditing ? Color(red: 0.2, green: 0.5, blue: 0.9) : Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color(.systemBackground).opacity(0.8).cornerRadius(12))
            )
        }
        .onTapGesture {
            isEditing = true
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: LoginViewModel())
} 
