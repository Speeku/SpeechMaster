import SwiftUI
import Combine

struct PasswordRequirement: Identifiable {
    let id = UUID()
    let description: String
    let validator: (String) -> Bool
    var isMet: Bool = false
}

class SignUpViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isFormValid: Bool = false
    @Published var passwordRequirements: [PasswordRequirement] = []
    @Published var dismissRequested: Bool = false
    @Published var showSuccess: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let supabaseManager = SupabaseManager.shared
    
    // MARK: - Initialization
    init() {
        setupPasswordRequirements()
        setupValidation()
    }
    
    // MARK: - Setup Methods
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
        
        // Update requirements whenever password changes
        $password
            .sink { [weak self] password in
                self?.updatePasswordRequirements(with: password)
            }
            .store(in: &cancellables)
    }
    
    private func updatePasswordRequirements(with password: String) {
        for i in 0..<passwordRequirements.count {
            passwordRequirements[i].isMet = passwordRequirements[i].validator(password)
        }
    }
    
    private func setupValidation() {
        // Combine all form inputs to determine validity
        Publishers.CombineLatest4($name, $email, $password, $confirmPassword)
            .map { [weak self] name, email, password, confirmPassword in
                guard let self = self else { return false }
                
                let isNameValid = name.count >= 2
                let isEmailValid = self.isValidEmail(email)
                let isPasswordValid = self.passwordRequirements.allSatisfy { $0.isMet }
                let doPasswordsMatch = password == confirmPassword
                
                return isNameValid && isEmailValid && isPasswordValid && doPasswordsMatch
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Sign Up Methods
    func signUp() {
        guard isFormValid else {
            if name.isEmpty {
                showError(message: "Please enter your name")
            } else if !isValidEmail(email) {
                showError(message: "Please enter a valid email address")
            } else if !passwordRequirements.allSatisfy({ $0.isMet }) {
                showError(message: "Please ensure your password meets all requirements")
            } else if password != confirmPassword {
                showError(message: "Passwords do not match")
            } else {
                showError(message: "Please complete all fields correctly")
            }
            return
        }
        
        isLoading = true
        
        // Use Supabase for user registration
        Task {
            do {
                let user = try await supabaseManager.signUp(
                    name: name,
                    email: email,
                    password: password
                )
                
                // Update UI on main thread
                await MainActor.run {
                    self.signUpSuccess(with: user)
                    self.isLoading = false
                }
            } catch let error as AuthError {
                await MainActor.run {
                    switch error {
                    case .emailAlreadyInUse:
                        self.showError(message: "This email is already registered. Please use another email or sign in.")
                    case .weakPassword:
                        self.showError(message: "Your password is too weak. Please choose a stronger password.")
                    case .networkError:
                        self.showError(message: "Network error. Please check your connection and try again.")
                    default:
                        self.showError(message: "An error occurred during sign up. Please try again.")
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.showError(message: "An unexpected error occurred: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    func signUpWithApple() {
        isLoading = true
        
        // TODO: Implement Apple Sign Up with Supabase
        // For now, we'll show an error that this is not implemented
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.showError(message: "Apple Sign Up is not implemented yet")
            self.isLoading = false
        }
    }
    
    func signUpWithGoogle() {
        isLoading = true
        
        // TODO: Implement Google Sign Up with Supabase
        // For now, we'll show an error that this is not implemented
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.showError(message: "Google Sign Up is not implemented yet")
            self.isLoading = false
        }
    }
    
    private func signUpSuccess(with user: User) {
        // Set the user as logged in
        HomeViewModel.shared.isLoggedIn = true
        HomeViewModel.shared.userName = user.name
        
        // Load scripts from Supabase
        HomeViewModel.shared.userDidLogIn()
        print("Triggered script loading from Supabase after sign up")
        
        // Store login state
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        // Show success message
        successMessage = "Account created successfully! Redirecting to login..."
        showSuccess = true
        
        // Navigate back to login after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.showSuccess = false
            self.goBackToLogin()
        }
        
        // Log success
        print("User created: \(user.name)")
    }
    
    // MARK: - Helper Methods
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorMessage = message
            self.showError = true
        }
    }
    
    func dismissError() {
        showError = false
    }
    
    func goBackToLogin() {
        // Ensure operations happen on the main thread
        DispatchQueue.main.async {
            // First, trigger the dismissRequested property
            self.dismissRequested = true
            
            // Then post the notification to ensure all listeners are notified
            NotificationCenter.default.post(name: NSNotification.Name("DismissSignUp"), object: nil)
            
            // Reset the property after a delay to avoid repeated triggers
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismissRequested = false
            }
        }
    }
} 