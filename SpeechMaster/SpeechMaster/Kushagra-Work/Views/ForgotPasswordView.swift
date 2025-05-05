import SwiftUI
import Combine
import Supabase

enum PasswordResetStep {
    case emailEntry
    case otpVerification
    case newPassword
    case success
}

class PasswordResetViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var otp: String = ""
    @Published var otpDigits: [String] = ["", "", "", "", "", ""] // 6-digit OTP
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var currentStep: PasswordResetStep = .emailEntry
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var passwordRequirements: [PasswordRequirement] = []
    
    private var cancellables = Set<AnyCancellable>()
    let supabaseManager = SupabaseManager.shared
    
    init() {
        setupPasswordRequirements()
        setupOTPBinding()
    }
    
    private func setupOTPBinding() {
        // Sync otpDigits with otp string
        $otpDigits
            .map { digits in
                digits.joined()
            }
            .assign(to: \.otp, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Password Requirements
    
    private func setupPasswordRequirements() {
        passwordRequirements = [
            PasswordRequirement(
                description: "At least 8 characters",
                validator: { $0.count >= 8 }
            ),
            PasswordRequirement(
                description: "At least one uppercase letter",
                validator: { $0.range(of: "[A-Z]", options: .regularExpression) != nil }
            ),
            PasswordRequirement(
                description: "At least one number",
                validator: { $0.range(of: "[0-9]", options: .regularExpression) != nil }
            ),
            PasswordRequirement(
                description: "At least one special character",
                validator: { $0.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil }
            )
        ]
    }
    
    func updatePasswordRequirements() {
        for i in 0..<passwordRequirements.count {
            passwordRequirements[i].isMet = passwordRequirements[i].validator(newPassword)
        }
    }
    
    // MARK: - Validation
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidOTP() -> Bool {
        // OTP is typically 4-6 digits
        return otp.count == 6 && otp.allSatisfy { $0.isNumber }
    }
    
    func arePasswordsValid() -> Bool {
        return passwordRequirements.allSatisfy { $0.isMet } && newPassword == confirmPassword
    }
    
    // MARK: - Actions
    
    func sendResetEmail() {
        guard isValidEmail() else {
            showErrorMessage("Please enter a valid email address")
            return
        }
        
        isLoading = true
        
        // Use Supabase to send reset code
        Task {
            do {
                // Call the forgot password endpoint with the email
                // This will trigger Supabase to send a password reset email with OTP
                try await supabaseManager.client.auth.resetPasswordForEmail(email)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    // Move to OTP verification step
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.currentStep = .otpVerification
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.showErrorMessage("Failed to send reset code: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func verifyOTP() {
        guard isValidOTP() else {
            showErrorMessage("Please enter a valid verification code")
            return
        }
        
        isLoading = true
        
        // Verify OTP with Supabase
        Task {
            do {
                // Verify the OTP for password reset
                let response = try await supabaseManager.client.auth.verifyOTP(
                    email: email,
                    token: otp,
                    type: .recovery
                )
                
                // If verification was successful
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    // Move to new password step
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.currentStep = .newPassword
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.showErrorMessage("Invalid verification code. Please try again.")
                }
            }
        }
    }
    
    func resetPassword() {
        guard arePasswordsValid() else {
            if !passwordRequirements.allSatisfy({ $0.isMet }) {
                showErrorMessage("Please ensure your new password meets all requirements")
            } else if newPassword != confirmPassword {
                showErrorMessage("Passwords do not match")
            }
            return
        }
        
        isLoading = true
        
        // Reset password with Supabase
        Task {
            do {
                // Use the correct syntax from the Supabase Swift documentation
                try await supabaseManager.client.auth.update(user: .init(password: newPassword))
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    // Show success
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.currentStep = .success
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.showErrorMessage("Failed to reset password: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        showError = false
    }
    
    func goBack() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            switch currentStep {
            case .otpVerification:
                currentStep = .emailEntry
            case .newPassword:
                currentStep = .otpVerification
            default:
                break
            }
        }
    }
}

struct ForgotPasswordView: View {
    @StateObject private var viewModel = PasswordResetViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @FocusState private var focusedField: FocusField?
    @FocusState private var otpFocusField: Int?
    
    enum FocusField: Hashable {
        case email, otp, newPassword, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - matching Login/SignUp style
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.9, green: 0.93, blue: 0.98)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Back button
                    HStack {
                        Button(action: {
                            if viewModel.currentStep != .emailEntry {
                                viewModel.goBack()
                            } else {
                                // Post notification then dismiss, ensuring it happens on main thread
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: NSNotification.Name("DismissForgotPassword"), object: nil)
                                    // Add a slight delay before dismissing to ensure notification is processed
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Logo and header
                            VStack(spacing: 20) {
                                // App icon
                                Image(systemName: "lock.rotation")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                                    .opacity(isAnimating ? 1 : 0)
                                    .offset(y: isAnimating ? 0 : -20)
                                    .animation(.easeOut(duration: 0.6), value: isAnimating)
                                
                                // Title and description
                                VStack(spacing: 8) {
                                    Text(viewModel.currentStep.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                                    
                                    Text(viewModel.currentStep.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 10)
                                .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)
                            }
                            .padding(.top, 10)
                            
                            // Form content based on current step
                            ZStack {
                                switch viewModel.currentStep {
                                case .emailEntry:
                                    emailEntryView
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                case .otpVerification:
                                    otpVerificationView
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                case .newPassword:
                                    newPasswordView
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                case .success:
                                    successView
                                        .transition(.opacity)
                                }
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentStep)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .animation(nil, value: viewModel.currentStep) // Prevent unnecessary animations
                }
                
                // Error alert
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
                withAnimation(.easeInOut(duration: 0.6)) {
                    isAnimating = true
                }
                
                // Set focus on the first field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    switch viewModel.currentStep {
                    case .emailEntry:
                        focusedField = .email
                    case .otpVerification:
                        otpFocusField = 0
                    case .newPassword:
                        focusedField = .newPassword
                    default:
                        break
                    }
                }
            }
            .onChange(of: viewModel.currentStep) { newValue in
                // Set focus when step changes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch newValue {
                    case .emailEntry:
                        focusedField = .email
                    case .otpVerification:
                        otpFocusField = 0
                    case .newPassword:
                        focusedField = .newPassword
                    default:
                        focusedField = nil
                        otpFocusField = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Step Views
    
    private var emailEntryView: some View {
        VStack(spacing: 24) {
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
            .submitLabel(.send)
            .onSubmit(viewModel.sendResetEmail)
            
            // Continue button
            actionButton(
                title: "Send Reset Code",
                icon: "arrow.right",
                isEnabled: viewModel.isValidEmail(),
                action: viewModel.sendResetEmail
            )
        }
    }
    
    private var otpVerificationView: some View {
        VStack(spacing: 24) {
            Text("If an account exists with this email, we have sent a verification email to reset your password for your email address:")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            Text(viewModel.email)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
            
            // OTP box-style input field
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitBox(
                        digit: $viewModel.otpDigits[index],
                        isFocused: otpFocusField == index,
                        onCommit: { moveToNextOTPField(from: index) }
                    )
                    .focused($otpFocusField, equals: index)
                    .onChange(of: viewModel.otpDigits[index]) { newValue in
                        if newValue.count == 1 {
                            moveToNextOTPField(from: index)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            
            // Continue button
            actionButton(
                title: "Verify Code",
                icon: "arrow.right",
                isEnabled: viewModel.isValidOTP(),
                action: viewModel.verifyOTP
            )
            
            // Resend code
            Button(action: {
                // Show loading state
                viewModel.isLoading = true
                
                // Use Supabase to resend reset code
                Task {
                    do {
                        // Call the forgot password endpoint again
                        try await viewModel.supabaseManager.client.auth.resetPasswordForEmail(viewModel.email)
                        
                        DispatchQueue.main.async {
                            viewModel.isLoading = false
                            // Show success message
                            viewModel.showErrorMessage("Verification code has been resent to your email")
                        }
                    } catch {
                        DispatchQueue.main.async {
                            viewModel.isLoading = false
                            viewModel.showErrorMessage("Failed to resend code: \(error.localizedDescription)")
                        }
                    }
                }
            }) {
                Text("Resend Code")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
            }
            .padding(.top, 8)
        }
    }
    
    private func moveToNextOTPField(from currentIndex: Int) {
        if currentIndex < 5 && !viewModel.otpDigits[currentIndex].isEmpty {
            otpFocusField = currentIndex + 1
        } else if currentIndex == 5 {
            otpFocusField = nil
            if viewModel.isValidOTP() {
                viewModel.verifyOTP()
            }
        }
    }
    
    private var newPasswordView: some View {
        VStack(spacing: 24) {
            // New password field
            FloatingLabelTextField(
                text: $viewModel.newPassword,
                placeholderText: "New Password",
                icon: "lock.fill",
                isSecure: true
            )
            .focused($focusedField, equals: .newPassword)
            .textContentType(.newPassword)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .confirmPassword
            }
            .onChange(of: viewModel.newPassword) { _ in
                viewModel.updatePasswordRequirements()
            }
            
            // Confirm password field
            FloatingLabelTextField(
                text: $viewModel.confirmPassword,
                placeholderText: "Confirm New Password",
                icon: "lock.shield.fill",
                isSecure: true
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit(viewModel.resetPassword)
            
            // Password requirements
            if !viewModel.newPassword.isEmpty {
                passwordRequirementsView
            }
            
            // Reset button
            actionButton(
                title: "Reset Password",
                icon: "checkmark",
                isEnabled: viewModel.arePasswordsValid(),
                action: viewModel.resetPassword
            )
        }
    }
    
    private var successView: some View {
        VStack(spacing: 30) {
            Circle()
                .fill(Color.green)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 16) {
                Text("Password Reset Complete")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                
                Text("Your password has been reset successfully. You can now log in with your new password.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Post notification then dismiss, ensuring it happens on main thread
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("DismissForgotPassword"), object: nil)
                    // Add a slight delay before dismissing to ensure notification is processed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismiss.callAsFunction()
                    }
                }
            }) {
                HStack {
                    Text("Return to Login")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.2, green: 0.5, blue: 0.9))
                )
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Helper Views
    
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
    
    private func actionButton(title: String, icon: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                
                Image(systemName: icon)
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
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.7)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
    
    private var errorAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissError()
                }
            
            VStack(spacing: 20) {
                // Show different icon and color based on whether it's an error or success message
                if viewModel.errorMessage.contains("success") || viewModel.errorMessage.contains("resent") {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.green)
                    
                    Text("Success")
                        .font(.headline)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                    
                    Text("Error")
                        .font(.headline)
                }
                
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
                
                Text(viewModel.currentStep.loadingText)
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

// MARK: - OTP Digit Box

struct OTPDigitBox: View {
    @Binding var digit: String
    var isFocused: Bool
    var onCommit: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color(red: 0.2, green: 0.5, blue: 0.9) : Color.gray.opacity(0.3), lineWidth: 2)
                .background(Color(.systemBackground).opacity(0.8).cornerRadius(8))
                .frame(width: 45, height: 60)
            
            TextField("", text: $digit)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2.bold())
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                .frame(width: 45, height: 60)
                .onSubmit(onCommit)
                .onChange(of: digit) { newValue in
                    // Limit to a single digit
                    if newValue.count > 1 {
                        digit = String(newValue.prefix(1))
                    }
                    
                    // Ensure only numbers
                    if !newValue.isEmpty && !newValue.allSatisfy({ $0.isNumber }) {
                        digit = ""
                    }
                }
        }
    }
}

// MARK: - Helper Extensions

extension PasswordResetStep {
    var title: String {
        switch self {
        case .emailEntry:
            return "Forgot Password"
        case .otpVerification:
            return "Verify Code"
        case .newPassword:
            return "Reset Password"
        case .success:
            return "Success"
        }
    }
    
    var description: String {
        switch self {
        case .emailEntry:
            return "Enter your email and we'll send you a verification code"
        case .otpVerification:
            return "Enter the verification code we sent to your email"
        case .newPassword:
            return "Create a new password for your account"
        case .success:
            return "Your password has been reset successfully"
        }
    }
    
    var loadingText: String {
        switch self {
        case .emailEntry:
            return "Sending code..."
        case .otpVerification:
            return "Verifying code..."
        case .newPassword:
            return "Resetting password..."
        case .success:
            return "Completing..."
        }
    }
}

#Preview {
    ForgotPasswordView()
} 
