import SwiftUI

struct RootView: View {
    @StateObject var viewModel = HomeViewModel.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedInStorage = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Show the auth coordinator when logged out
            if !viewModel.isLoggedIn {
                AuthCoordinator()
                    .transition(.opacity)
                    .environmentObject(viewModel)
            } else {
                // Show the main content when logged in
                LandingPageView()
                    .transition(.opacity)
                    .environmentObject(viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.isLoggedIn)
        .onAppear {
            // Check if user is logged in from UserDefaults
            let savedLoginState = UserDefaults.standard.bool(forKey: "isLoggedIn")
            print("RootView appeared: Stored login state is \(savedLoginState)")
            
            // If the stored login state differs from the viewModel state, update the viewModel
            if savedLoginState != viewModel.isLoggedIn {
                viewModel.isLoggedIn = savedLoginState
                print("Updated viewModel.isLoggedIn to \(savedLoginState)")
            }
        }
        // Listen for logout notifications
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserLoggedOut"))) { _ in
            viewModel.isLoggedIn = false
            print("Received logout notification, updated isLoggedIn to false")
        }
        .preferredColorScheme(nil) // Allow system to control dark/light mode
    }
}

#Preview {
    RootView()
} 
