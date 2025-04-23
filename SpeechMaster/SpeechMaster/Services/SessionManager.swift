import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    
    private let supabaseManager = SupabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Listen for changes to currentUser in SupabaseManager
        supabaseManager.$currentUser
            .map { $0 != nil }
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
        
        // Check for existing session on init
        checkSession()
    }
    
    func checkSession() {
        isLoading = true
        
        Task {
            do {
                if let user = try await supabaseManager.getCurrentUser() {
                    // We have a valid session
                    await MainActor.run {
                        HomeViewModel.shared.isLoggedIn = true
                        HomeViewModel.shared.userName = user.name
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        self.isLoading = false
                    }
                } else {
                    // No valid session
                    await MainActor.run {
                        HomeViewModel.shared.isLoggedIn = false
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error checking session: \(error)")
                
                await MainActor.run {
                    HomeViewModel.shared.isLoggedIn = false
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await supabaseManager.signOut()
                
                await MainActor.run {
                    HomeViewModel.shared.isLoggedIn = false
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                }
            } catch {
                print("Error signing out: \(error)")
            }
        }
    }
} 