import SwiftUI
import Combine

enum AuthRoute {
    case login
    case signUp
    case forgotPassword
}

struct AuthCoordinator: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var currentRoute: AuthRoute = .login
    @State private var loginViewModel = LoginViewModel()
    @State private var signUpViewModel = SignUpViewModel()
    @State private var transition: AnyTransition = .opacity
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            switch currentRoute {
            case .login:
                LoginView(viewModel: loginViewModel)
                    .transition(.opacity)
                    .onReceive(routePublisher(for: loginViewModel)) { route in
                        // Prevent navigation during animation
                        guard !isAnimating else { return }
                        
                        isAnimating = true
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            transition = route == .signUp ? .move(edge: .trailing) : .move(edge: .bottom)
                            self.currentRoute = route
                        }
                        
                        // Reset animation flag after transition completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isAnimating = false
                        }
                    }
                    // Listen for login success directly
                    .onReceive(loginSuccessPublisher()) { _ in
                        print("AuthCoordinator detected login success")
                    }
                
            case .signUp:
                SignUpView(viewModel: signUpViewModel)
                    .transition(transition)
                    .onReceive(backToLoginPublisher(for: signUpViewModel)) { _ in
                        // Prevent navigation during animation
                        guard !isAnimating else { return }
                        
                        isAnimating = true
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            transition = .move(edge: .leading)
                            self.currentRoute = .login
                        }
                        
                        // Reset animation flag after transition completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isAnimating = false
                        }
                    }
                
            case .forgotPassword:
                ForgotPasswordView()
                    .transition(transition)
                    .onReceive(backToLoginPublisher(for: nil)) { _ in
                        // Prevent navigation during animation
                        guard !isAnimating else { return }
                        
                        isAnimating = true
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            transition = .move(edge: .top)
                            self.currentRoute = .login
                        }
                        
                        // Reset animation flag after transition completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isAnimating = false
                        }
                    }
            }
        }
    }
    
    // MARK: - Route Publishers
    
    private func routePublisher(for viewModel: LoginViewModel) -> AnyPublisher<AuthRoute, Never> {
        // Create a publisher that emits when the user wants to sign up
        let signUpPublisher = viewModel.$showSignUpScreen
            .filter { $0 }
            .map { _ in AuthRoute.signUp }
        
        // Create a publisher that emits when the user wants to reset password
        let forgotPasswordPublisher = viewModel.$showForgotPasswordScreen
            .filter { $0 }
            .map { _ in AuthRoute.forgotPassword }
        
        // Merge the publishers
        return Publishers.Merge(signUpPublisher, forgotPasswordPublisher)
            .eraseToAnyPublisher()
    }
    
    private func loginSuccessPublisher() -> AnyPublisher<Void, Never> {
        // Create a publisher that emits when login succeeds
        return NotificationCenter.default
            .publisher(for: NSNotification.Name("UserLoggedIn"))
            .map { _ in () }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func backToLoginPublisher(for viewModel: SignUpViewModel?) -> AnyPublisher<Void, Never> {
        // If we have a SignUpViewModel, listen to its dismiss property and notification
        if let viewModel = viewModel {
            // Create a debounced publisher for navigation events
            let navigationPublisher = Publishers.Merge(
                // Listen for the notification
                NotificationCenter.default
                    .publisher(for: NSNotification.Name("DismissSignUp"))
                    .map { _ in () },
                
                // Listen for the property change
                viewModel.$dismissRequested
                    .filter { $0 }
                    .map { _ in () }
            )
            .receive(on: RunLoop.main)
            // Add debounce to prevent multiple rapid navigation attempts
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            // Only take the first event to avoid multiple navigation triggers
            .first()
            // Add a delay to ensure all UI updates complete before navigating
            .delay(for: .milliseconds(50), scheduler: RunLoop.main)
            // Share the result to avoid multiple subscriptions triggering multiple navigations
            .share()
            
            return navigationPublisher.eraseToAnyPublisher()
        } else {
            // For ForgotPasswordView, listen to a notification that indicates the user wants to go back
            return NotificationCenter.default
                .publisher(for: NSNotification.Name("DismissForgotPassword"))
                .map { _ in () }
                .receive(on: RunLoop.main)
                .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
}

#Preview {
    AuthCoordinator()
} 