import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isFormValid: Bool = false
    @Published var showSignUpScreen: Bool = false
    @Published var showForgotPasswordScreen: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let supabaseManager = SupabaseManager.shared
    
    // MARK: - Initialization
    init() {
        setupValidation()
    }
    
    // MARK: - Form Validation
    private func setupValidation() {
        Publishers.CombineLatest($email, $password)
            .map { [weak self] email, password in
                return self?.isValidEmail(email) == true && password.count >= 6
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Authentication Methods
    func login() {
        guard isFormValid else {
            showError(message: "Please enter a valid email and password")
            return
        }
        
        isLoading = true
        
        // Use Supabase for authentication
        Task {
            do {
                let user = try await supabaseManager.signIn(email: email, password: password)
                
                // Update UI on main thread
                await MainActor.run {
                    self.loginSuccess(with: user)
                    self.isLoading = false
                    
                    // Post notification for successful login
                    NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
                    print("Posted UserLoggedIn notification")
                }
            } catch let error as AuthError {
                await MainActor.run {
                    switch error {
                    case .invalidCredentials:
                        self.showError(message: "Invalid email or password. Please try again.")
                    case .networkError:
                        self.showError(message: "Network error. Please check your connection and try again.")
                    default:
                        self.showError(message: "An error occurred. Please try again.")
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
    
    func signInWithApple() {
        isLoading = true
        
        // TODO: Implement Apple Sign In with Supabase
        // For now, we'll show an error that this is not implemented
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showError(message: "Apple Sign In is not implemented yet")
            self.isLoading = false
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        
        // TODO: Implement Google Sign In with Supabase
        // For now, we'll show an error that this is not implemented
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showError(message: "Google Sign In is not implemented yet")
            self.isLoading = false
        }
    }
    
    private func loginSuccess(with user: User) {
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async {
            print("Login successful! Setting user as logged in")
            
            // Set the user as logged in
            HomeViewModel.shared.isLoggedIn = true
            HomeViewModel.shared.userName = user.name
            
            // Load scripts from Supabase
            HomeViewModel.shared.userDidLogIn()
            print("Triggered script loading from Supabase")
            
            // Store login state in UserDefaults
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.synchronize()
            
            print("Login state updated: isLoggedIn = \(HomeViewModel.shared.isLoggedIn)")
            
            // Post notification that user logged in successfully
            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
        }
    }
    
    // MARK: - Navigation Methods
    func showSignUp() {
        // Set flag immediately on main thread to trigger navigation
        DispatchQueue.main.async {
            self.showSignUpScreen = true
            
            // Reset after a delay to allow navigation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showSignUpScreen = false
            }
        }
    }
    
    func forgotPassword() {
        // Set flag immediately on main thread to trigger navigation
        DispatchQueue.main.async {
            self.showForgotPasswordScreen = true
            
            // Reset after a delay to allow navigation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showForgotPasswordScreen = false
            }
        }
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
} 