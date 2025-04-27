import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false
    @FocusState private var focusedField: FocusField?
    @Environment(\.presentationMode) private var presentationMode
    
    // For OTP verification
    @State private var otpDigits: [String] = ["", "", "", "", "", ""]
    @FocusState private var otpFocusField: Int?
    @State private var isVerifying = false
    @State private var showOtpError = false
    @State private var otpErrorMessage = ""
    
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
                .blur(radius: viewModel.showEmailVerification ? 5 : 0)
                .disabled(viewModel.showEmailVerification)
                
                // OTP Verification Overlay
                if viewModel.showEmailVerification {
                    otpVerificationOverlay
                        .transition(.opacity)
                        .zIndex(3)
                }
                
                // Loading view
                if viewModel.isLoading || isVerifying {
                    loadingView
                        .zIndex(4)
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
                    .zIndex(5)
                }
                
                // Show error alert if needed
                if viewModel.showError {
                    errorAlert
                        .zIndex(5)
                }
                
                // OTP Error Alert
                if showOtpError {
                    otpErrorAlert
                        .zIndex(5)
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
    }
    
    // MARK: - OTP Verification Components
    
    private var otpVerificationOverlay: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "envelope.badge.shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                
                Text("Verify Your Email")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                
                Text("Enter the verification code sent to your email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text(viewModel.email)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
            }
            
            // OTP Boxes
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitBox(
                        digit: $otpDigits[index],
                        isFocused: otpFocusField == index,
                        onCommit: { moveToNextOTPField(from: index) }
                    )
                    .focused($otpFocusField, equals: index)
                    .onChange(of: otpDigits[index]) { newValue in
                        if newValue.count == 1 {
                            moveToNextOTPField(from: index)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            
            // Buttons
            VStack(spacing: 16) {
                // Verify button
                Button(action: verifyOTP) {
                    HStack {
                        Text("Verify Email")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "checkmark")
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
                .disabled(!isValidOTP() || isVerifying)
                .opacity(isValidOTP() ? 1.0 : 0.7)
                
                // Resend button
                Button(action: resendOTP) {
                    Text("Didn't receive a code? Resend")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                }
                
                // Cancel button
                Button(action: {
                    withAnimation {
                        viewModel.showEmailVerification = false
                        // Reset OTP
                        otpDigits = ["", "", "", "", "", ""]
                    }
                }) {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
        )
        .padding(20)
        .onAppear {
            // Send OTP when overlay appears
            sendOTP()
            
            // Set focus to first OTP field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                otpFocusField = 0
            }
        }
    }
    
    private var otpErrorAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showOtpError = false
                }
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                
                Text("Verification Error")
                    .font(.headline)
                
                Text(otpErrorMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                
                Button(action: { showOtpError = false }) {
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
    
    // MARK: - OTP Verification Methods
    
    private func isValidOTP() -> Bool {
        let otp = otpDigits.joined()
        return otp.count == 6 && otp.allSatisfy { $0.isNumber }
    }
    
    private func moveToNextOTPField(from currentIndex: Int) {
        if currentIndex < 5 && !otpDigits[currentIndex].isEmpty {
            otpFocusField = currentIndex + 1
        } else if currentIndex == 5 {
            otpFocusField = nil
            if isValidOTP() {
                verifyOTP()
            }
        }
    }
    
    private func sendOTP() {
        Task {
            do {
                print("Sending OTP to \(viewModel.email)")
                try await SupabaseManager.shared.sendEmailVerificationOTP(email: viewModel.email)
                print("OTP sent successfully to \(viewModel.email)")
            } catch {
                print("Failed to send OTP: \(error)")
                await MainActor.run {
                    otpErrorMessage = "Failed to send verification code: \(error.localizedDescription)"
                    showOtpError = true
                }
            }
        }
    }
    
    private func resendOTP() {
        // Reset OTP fields
        otpDigits = ["", "", "", "", "", ""]
        otpFocusField = 0
        
        // Send new OTP
        sendOTP()
    }
    
    private func verifyOTP() {
        let otp = otpDigits.joined()
        print("Verifying OTP: \(otp)")
        
        isVerifying = true
        
        Task {
            do {
                let verified = try await SupabaseManager.shared.verifyOTP(email: viewModel.email, token: otp)
                
                await MainActor.run {
                    isVerifying = false
                    
                    if verified {
                        print("OTP verification successful")
                        // Clear OTP overlay
                        viewModel.showEmailVerification = false
                        // Complete registration
                        viewModel.onEmailVerified()
                    } else {
                        print("OTP verification failed")
                        otpErrorMessage = "Invalid verification code. Please try again."
                        showOtpError = true
                    }
                }
            } catch {
                print("Error verifying OTP: \(error)")
                await MainActor.run {
                    isVerifying = false
                    otpErrorMessage = "Error verifying code: \(error.localizedDescription)"
                    showOtpError = true
                }
            }
        }
    }
    
    // MARK: - Existing View Components
    
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

// Add this helper wrapper to ensure proper navigation
struct EmailVerificationNavigationWrapper: View {
    let email: String
    let onVerificationSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            EmailVerificationView(
                viewModel: EmailVerificationViewModel(email: email),
                onVerificationSuccess: onVerificationSuccess
            )
        }
    }
}

// UIKit-based presenter for reliable modal presentation
struct ModalPresenter<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let content: Content
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            // If not already presented, present the modal
            if uiViewController.presentedViewController == nil {
                let hostingController = UIHostingController(rootView: content)
                hostingController.modalPresentationStyle = .fullScreen
                uiViewController.present(hostingController, animated: true)
            }
        } else {
            // If presented but should be dismissed
            if uiViewController.presentedViewController != nil {
                uiViewController.dismiss(animated: true)
            }
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        if uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: false)
        }
    }
} 