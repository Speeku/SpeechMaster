import SwiftUI
import Combine

class EmailVerificationViewModel: ObservableObject {
    @Published var otp: String = ""
    @Published var otpDigits: [String] = ["", "", "", "", "", ""] // 6-digit OTP
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var verificationSuccess: Bool = false
    @Published var email: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let supabaseManager = SupabaseManager.shared
    
    init(email: String) {
        self.email = email
        setupOTPBinding()
        
        // Send verification OTP when the view is initialized
        Task {
            do {
                print("Sending verification OTP to \(email)")
                try await supabaseManager.sendEmailVerificationOTP(email: email)
                print("Successfully sent verification OTP to \(email)")
            } catch {
                print("Failed to send verification OTP: \(error.localizedDescription)")
                await MainActor.run {
                    showErrorMessage("Failed to send verification code: \(error.localizedDescription)")
                }
            }
        }
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
    
    func isValidOTP() -> Bool {
        return otp.count == 6 && otp.allSatisfy { $0.isNumber }
    }
    
    func verifyEmail() {
        guard isValidOTP() else {
            showErrorMessage("Please enter a valid verification code")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Call Supabase to verify the OTP
                let verified = try await supabaseManager.verifyOTP(email: email, token: otp)
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if verified {
                        // Set success flag to trigger onVerificationSuccess callback
                        self.verificationSuccess = true
                    } else {
                        self.showErrorMessage("Invalid verification code. Please try again.")
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showErrorMessage("Error verifying email: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resendOTP() {
        isLoading = true
        
        Task {
            do {
                // Call Supabase to resend OTP
                try await supabaseManager.resendOTP(email: email)
                
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showErrorMessage("Error sending code: \(error.localizedDescription)")
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
}

struct EmailVerificationView: View {
    @ObservedObject var viewModel: EmailVerificationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false
    @FocusState private var otpFocusField: Int?
    
    var onVerificationSuccess: () -> Void
    
    // Add a dedicated method to dismiss that handles all scenarios
    private func dismissView() {
        print("Attempting to dismiss EmailVerificationView")
        
        // Try multiple dismiss approaches to ensure it works
        dismiss()
        presentationMode.wrappedValue.dismiss()
        
        // Also post a notification that UIKit can observe
        NotificationCenter.default.post(name: NSNotification.Name("DismissEmailVerification"), object: nil)
    }
    
    var body: some View {
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
                // Header
                VStack(spacing: 20) {
                    // App icon
                    Image(systemName: "envelope.badge.shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: isAnimating)
                    
                    // Title and description
                    VStack(spacing: 8) {
                        Text("Verify Your Email")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.6))
                        
                        Text("Enter the verification code sent to your email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 10)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)
                }
                .padding(.top, 40)
                
                // OTP Verification Form
                VStack(spacing: 24) {
                    Text("We've sent a verification code to")
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
                    
                    // Verify button
                    Button(action: viewModel.verifyEmail) {
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
                    .disabled(!viewModel.isValidOTP() || viewModel.isLoading)
                    .opacity(viewModel.isValidOTP() ? 1.0 : 0.7)
                    .animation(.spring(response: 0.3), value: viewModel.isValidOTP())
                    
                    // Resend code
                    Button(action: viewModel.resendOTP) {
                        Text("Didn't receive a code? Resend")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                    }
                    .padding(.top, 8)
                    .disabled(viewModel.isLoading)
                    
                    // Add a stronger Cancel button at the bottom
                    Button(action: dismissView) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.vertical, 12)
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                Spacer()
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: dismissView) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                }
            }
        }
        .onAppear {
            print("EmailVerificationView appeared for email: \(viewModel.email)")
            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
            
            // Set focus on the first OTP field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                otpFocusField = 0
            }
        }
        .onChange(of: viewModel.verificationSuccess) { success in
            print("Verification success changed to: \(success)")
            if success {
                print("Calling onVerificationSuccess")
                onVerificationSuccess()
                // Dismiss this view after verification success
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismissView()
                }
            }
        }
    }
    
    private func moveToNextOTPField(from currentIndex: Int) {
        if currentIndex < 5 && !viewModel.otpDigits[currentIndex].isEmpty {
            otpFocusField = currentIndex + 1
        } else if currentIndex == 5 {
            otpFocusField = nil
            if viewModel.isValidOTP() {
                viewModel.verifyEmail()
            }
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
                
                Text("Verifying email...")
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
    EmailVerificationView(
        viewModel: EmailVerificationViewModel(email: "user@example.com"),
        onVerificationSuccess: {}
    )
} 