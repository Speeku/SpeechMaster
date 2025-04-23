import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false
    @FocusState private var focusedField: FocusField?
    @Environment(\.presentationMode) private var presentationMode
    
    enum FocusField: Hashable {
        case name, email, password, confirmPassword
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background gradient - lighter, more professional shade - matching LoginView
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
                            .padding(.top, 20)
                        
                        // Welcome text
                        welcomeTextView
                            .padding(.bottom, 10)
                        
                        // Form fields
                        VStack(spacing: 16) {
                            // Name field
                            FloatingLabelTextField(
                                text: $viewModel.name,
                                placeholderText: "Full Name",
                                icon: "person.fill"
                            )
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }
                            
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
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .confirmPassword
                            }
                            
                            // Confirm Password field
                            FloatingLabelTextField(
                                text: $viewModel.confirmPassword,
                                placeholderText: "Confirm Password",
                                icon: "lock.shield.fill",
                                isSecure: true
                            )
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                viewModel.signUp()
                            }
                            
                            // Password requirements
                            if !viewModel.password.isEmpty {
                                passwordRequirementsView
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign up button - Matching login button style
                        signUpButton
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
                        .padding(.vertical, 5)
                        
                        // Social signup buttons - Matching login style
                        VStack(spacing: 10) {
                            socialSignupButton(
                                icon: "apple.logo",
                                text: "Sign up with Apple",
                                backgroundColor: colorScheme == .dark ? .white : .black,
                                textColor: colorScheme == .dark ? .black : .white,
                                action: viewModel.signUpWithApple
                            )
                            
                            socialSignupButton(
                                icon: "g.circle.fill",
                                text: "Sign up with Google",
                                backgroundColor: Color(red: 0.98, green: 0.98, blue: 0.98),
                                textColor: .black,
                                action: viewModel.signUpWithGoogle
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Terms and privacy
                        VStack(spacing: 4) {
                            Text("By signing up, you agree to our")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            HStack(spacing: 4) {
                                Button(action: {}) {
                                    Text("Terms of Service")
                                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                
                                Text("and")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                
                                Button(action: {}) {
                                    Text("Privacy Policy")
                                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                    }
                }
                
                // Loading view
                if viewModel.isLoading {
                    loadingView
                }
                
                // Success message
                if viewModel.showSuccess {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text(viewModel.successMessage)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.systemBackground))
                        )
                        .shadow(radius: 10)
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
            
            // Show error alert if needed
            if viewModel.showError {
                errorAlert
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - View Components
    
    private var logoView: some View {
        VStack(spacing: 15) {
            Image("app_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : -20)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
            
            Text("Eloquent")
                .font(.custom("SonsieOne-Regular", size: 28))
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : -10)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
        }
    }
    
    private var welcomeTextView: some View {
        VStack(spacing: 8) {
            Text("Create Account")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
            
            Text("Join us and start your speech journey")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 10)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
    }
    
    private var passwordRequirementsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password requirements:")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(viewModel.passwordRequirements) { requirement in
                HStack(spacing: 10) {
                    Image(systemName: requirement.isMet ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(requirement.isMet ? .green : .gray)
                        .font(.caption)
                    
                    Text(requirement.description)
                        .foregroundColor(requirement.isMet ? Color(red: 0.2, green: 0.3, blue: 0.6) : .gray)
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    
    private var signUpButton: some View {
        Button(action: viewModel.signUp) {
            HStack {
                Text("Create Account")
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
    
    private func socialSignupButton(icon: String, text: String, backgroundColor: Color, textColor: Color, action: @escaping () -> Void) -> some View {
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
                
                Text("Error")
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
                
                Text("Creating account...")
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

#Preview {
    SignUpView(viewModel: SignUpViewModel())
} 