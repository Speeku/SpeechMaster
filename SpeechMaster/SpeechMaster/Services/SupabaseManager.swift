import Foundation
import Supabase
import Combine
import SwiftUI
import UIKit

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // Current user data
    @Published var currentUser: User?
    
    private let supabaseUrl = "https://zvzudspxufrliprownhr.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2enVkc3B4dWZybGlwcm93bmhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk3MzM2MjEsImV4cCI6MjA1NTMwOTYyMX0.5vXROUiBYj1vYkkWHgX-mCrmFAg5-O_rWskXGFwcuwM"
    
    let client: SupabaseClient
    
    // For handling app state changes
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseUrl)!,
            supabaseKey: supabaseAnonKey
        )
        
        // Check for existing session on app launch
        Task {
            do {
                currentUser = try await getCurrentUser()
            } catch {
                print("No active session found: \(error)")
            }
        }
        
        // Set up app state observation using the environment
        setupAppStateObserver()
    }
    
    // MARK: - App State Observation
    
    private func setupAppStateObserver() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                print("App became active - refreshing data")
                self?.refreshCurrentSession()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { _ in
                print("App will resign active state")
            }
            .store(in: &cancellables)
    }
    
    private func refreshCurrentSession() {
        Task {
            do {
                // Check if we still have a valid session
                if let session = try? await getCurrentSession() {
                    print("Session is still valid, refreshing user data")
                    
                    // If session is valid but currentUser is nil, fetch the user
                    if currentUser == nil {
                        currentUser = try await getCurrentUser()
                    }
                    
                    // Post notification to refresh script data in HomeViewModel
                    await MainActor.run {
                        NotificationCenter.default.post(name: NSNotification.Name("RefreshSupabaseData"), object: nil)
                    }
                } else {
                    print("No valid session found after returning to foreground")
                    // Clear currentUser if session is invalid
                    await MainActor.run {
                        currentUser = nil
                    }
                }
            } catch {
                print("Error refreshing session: \(error)")
            }
        }
    }
    
    // Method to manually trigger data refresh
    func refreshData() {
        refreshCurrentSession()
    }
    
    // MARK: - Authentication Methods
    
    func signUp(name: String, email: String, password: String) async throws -> User {
        // Step 1: Sign up with Supabase Auth to create entry in auth.users
        print("Starting user registration process for \(email)")
        
        let authResponse: AuthResponse
        do {
            authResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            print("Auth signup successful for \(email)")
        } catch {
            print("Auth signup failed for \(email): \(error)")
            throw AuthError.unknown("Auth signup failed: \(error.localizedDescription)")
        }
        
        guard let session = authResponse.session else {
            print("No session returned after signup for \(email)")
            throw AuthError.unknown("Failed to create user account - no session")
        }
        
        // Check if user ID exists - FIX for UUID optional binding error
        if authResponse.user.id == nil {
            print("No user ID returned after signup for \(email)")
            throw AuthError.unknown("Failed to create user account - no user ID")
        }
        
        let userId = authResponse.user.id
        print("User created in auth.users with ID: \(userId.uuidString)")
        
        // Step 2: Explicitly insert the user into the public.User table
        do {
            // Create a properly typed dictionary for Postgres JSON insert
            // Use PostgresJSONB type to insert directly as a string which will be parsed by Postgres
            let jsonString = """
            {
                "id": "\(userId.uuidString)",
                "email": "\(email)",
                "name": "\(name)",
                "preferences": {
                    "isDarkMode": false,
                    "notificationsEnabled": true,
                    "emailNotificationsEnabled": true
                }
            }
            """
            
            // Use raw SQL query with parameters to avoid Encodable issues with mixed types
            let result = try await client.database
                .rpc(
                    "insert_user_record",
                    params: [
                        "user_id": userId.uuidString,
                        "user_email": email,
                        "user_name": name,
                        "user_preferences": """
                            {
                                "isDarkMode": false,
                                "notificationsEnabled": true,
                                "emailNotificationsEnabled": true
                            }
                            """
                    ]
                )
                .execute()
            
            print("User inserted using database RPC function")
            
            // Fetch the user data from public.User table
            let user = try await fetchUser(userId: userId)
            
            print("User successfully inserted into public.User table")
            
            // Update current user
            await MainActor.run {
                self.currentUser = user
            }
            
            return user
        } catch {
            print("Error inserting user into public.User table: \(error)")
            
            // If insertion fails, try to clean up the auth user to avoid orphaned accounts
            do {
                print("Attempting to clean up auth user after failed public.User insertion")
                try await client.auth.admin.deleteUser(id: userId.uuidString)
                print("Auth user cleanup successful")
            } catch {
                print("Failed to clean up auth user: \(error)")
            }
            
            throw AuthError.unknown("Failed to insert user data into public.User table: \(error.localizedDescription)")
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        print("Attempting sign in for \(email)")
        
        // Sign in with Supabase Auth
        let authResponse = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        // Check if user ID exists
        if authResponse.user.id == nil {
            print("No user ID in auth response for \(email)")
            throw AuthError.invalidCredentials
        }
        
        let userId = authResponse.user.id
        print("Successfully signed in with auth.users ID: \(userId.uuidString)")
        
        // Fetch the user data from public.User table
        do {
            let user = try await fetchUser(userId: userId)
            print("Successfully fetched user data from public.User table")
            
            // Update last login date
            Task {
                try await updateLastLoginDate(userId: userId)
            }
            
            // Update current user
            await MainActor.run {
                self.currentUser = user
            }
            
            return user
        } catch {
            print("Error fetching user from public.User table after signin: \(error)")
            throw AuthError.unknown("User authenticated but data not found: \(error.localizedDescription)")
        }
    }
    
    func signOut() async throws {
        print("Signing out user")
        try await client.auth.signOut()
        
        await MainActor.run {
            self.currentUser = nil
        }
        print("User signed out successfully")
    }
    
    // MARK: - User Data Methods
    
    func fetchUser(userId: UUID) async throws -> User {
        print("Fetching user with ID: \(userId.uuidString)")
        
        let response = try await client
            .from("User")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
        
        let data = response.data
        
        // Parse the JSON data into a User object
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Convert data to JSON string for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("User data JSON response: \(jsonString)")
        }
        
        let user = try decoder.decode(User.self, from: data)
        return user
    }
    
    func updateLastLoginDate(userId: UUID) async throws {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: now)
        
        print("Updating last login date for user \(userId.uuidString) to \(dateString)")
        
        _ = try await client
            .from("User")
            .update(["last_login_date": dateString])
            .eq("id", value: userId.uuidString)
            .execute()
        
        print("Last login date updated successfully")
    }
    
    func updateUserPreferences(preferences: User.UserPreferences) async throws {
        guard let userId = currentUser?.id else {
            print("Cannot update preferences: no current user")
            throw AuthError.userNotFound
        }
        
        let preferencesJson: [String: Bool] = [
            "isDarkMode": preferences.isDarkMode,
            "notificationsEnabled": preferences.notificationsEnabled,
            "emailNotificationsEnabled": preferences.emailNotificationsEnabled
        ]
        
        print("Updating preferences for user \(userId.uuidString): \(preferencesJson)")
        
        // Convert preferences to JSON string first
        let encoder = JSONEncoder()
        let preferencesData = try encoder.encode(preferencesJson)
        guard let preferencesString = String(data: preferencesData, encoding: .utf8) else {
            throw AuthError.unknown("Failed to encode preferences")
        }
        
        // Use raw SQL update to avoid Encodable issues
        let result = try await client.database
            .rpc(
                "update_user_preferences",
                params: [
                    "user_id": userId.uuidString,
                    "user_preferences": preferencesString
                ]
            )
            .execute()
        
        print("Preferences updated successfully")
        
        // Update local user object
        if var updatedUser = currentUser {
            updatedUser.preferences = preferences
            
            await MainActor.run {
                self.currentUser = updatedUser
            }
        }
    }
    
    func getCurrentSession() async throws -> Auth.Session? {
        return try await client.auth.session
    }
    
    func getCurrentUser() async throws -> User? {
        let session = try? await getCurrentSession()
        if session == nil {
            print("No active session found")
            return nil
        }
        
        // Get user ID from session
        guard let userId = session?.user.id else {
            print("Session exists but has no user ID")
            return nil
        }
        
        print("Found active session with user ID: \(userId.uuidString)")
        
        do {
            let user = try await fetchUser(userId: userId)
            print("Successfully loaded current user data")
            return user
        } catch {
            print("Error fetching current user data: \(error)")
            return nil
        }
    }
    
    // MARK: - Profile Image Management
    
    func uploadProfileImage(userId: UUID, imageData: Data) async throws -> String {
        print("Uploading profile image for user \(userId.uuidString)")
        
        let fileName = "\(userId.uuidString)_\(Date().timeIntervalSince1970).jpg"
        let storageResponse = try await client.storage
            .from("profile-photo")
            .upload(
                fileName,
                data: imageData,
                options: .init(contentType: "image/jpeg")
            )
        
        print("Image uploaded successfully to path: \(fileName)")
        
        // Update the user's profile with the image URL
        _ = try await client
            .from("User")
            .update(["profile_image_url": fileName])
            .eq("id", value: userId.uuidString)
            .execute()
        
        print("User profile updated with new image URL")
        
        // Update current user object with the new profile image URL
        if var updatedUser = currentUser {
            updatedUser.profileImageURL = fileName
            
            await MainActor.run {
                self.currentUser = updatedUser
            }
        }
        
        return fileName
    }
    
    func downloadProfileImage(path: String) async throws -> Data {
        print("Downloading profile image from path: \(path)")
        
        let imageData = try await client.storage
            .from("profile-photo")
            .download(path: path)
        
        print("Image downloaded successfully, size: \(imageData.count) bytes")
        
        return imageData
    }
    
    func getProfileImageURL(path: String) async throws -> URL? {
        guard !path.isEmpty else {
            print("Empty path provided for profile image URL")
            return nil
        }
        
        print("Getting profile image URL for path: \(path)")
        
        // createSignedURL returns a URL object directly, not a string
        let url = try await client.storage
            .from("profile-photo")
            .createSignedURL(path: path, expiresIn: 3600)
        
        print("Profile image signed URL created: \(url)")
        
        return url
    }
    
    // MARK: - Script Methods
    
    /// Inserts a new script in the database
    func createScript(title: String, scriptText: String, isPinned: Bool = false) async throws -> Script {
        print("Creating new script with title: \(title)")
        
        guard let currentUserId = currentUser?.id else {
            print("Cannot create script: no current user")
            throw AuthError.userNotFound
        }
        
        // Create a properly structured type instead of using [String: Any]
        struct ScriptInsert: Encodable {
            let title: String
            let script_text: String
            let is_Pinned: Bool
            let user_id: String
        }
        
        let scriptData = ScriptInsert(
            title: title,
            script_text: scriptText,
            is_Pinned: isPinned,
            user_id: currentUserId.uuidString
        )
        
        do {
            let response = try await client
                .from("Script")
                .insert(scriptData)
                .select()
                .single()
                .execute()
            
            // Parse response into Script object
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Debug: print the JSON response
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Created script response: \(jsonString)")
            }
            
            // Map from Supabase response to Swift model
            let script = try mapScriptFromResponse(responseData: response.data)
            print("Script created successfully with ID: \(script.id)")
            
            return script
        } catch {
            print("Error creating script: \(error)")
            throw error
        }
    }
    
    /// Fetches all scripts for the current user
    func fetchScripts() async throws -> [Script] {
        print("Fetching all scripts for current user")
        
        guard let currentUserId = currentUser?.id else {
            print("Cannot fetch scripts: no current user")
            throw AuthError.userNotFound
        }
        
        do {
            let response = try await client
                .from("Script")
                .select("*")
                .eq("user_id", value: currentUserId.uuidString)
                .order("created_at", ascending: false)
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched scripts response: \(jsonString)")
            }
            
            // Parse the JSON array into Script objects
            let scripts = try mapScriptsFromResponse(responseData: response.data)
            print("Fetched \(scripts.count) scripts successfully")
            
            return scripts
        } catch {
            print("Error fetching scripts: \(error)")
            throw error
        }
    }
    
    /// Fetches a specific script by ID
    func fetchScript(id: UUID) async throws -> Script {
        print("Fetching script with ID: \(id.uuidString)")
        
        do {
            let response = try await client
                .from("Script")
                .select("*")
                .eq("id", value: id.uuidString)
                .single()
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched single script response: \(jsonString)")
            }
            
            // Convert response to Script object
            let script = try mapScriptFromResponse(responseData: response.data)
            print("Successfully fetched script with title: \(script.title)")
            
            return script
        } catch {
            print("Error fetching script \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Updates an existing script
    func updateScript(id: UUID, title: String? = nil, scriptText: String? = nil, isPinned: Bool? = nil) async throws -> Script {
        print("Updating script with ID: \(id.uuidString)")
        
        // Create a properly structured type for updating script data
        struct ScriptUpdate: Encodable {
            var title: String?
            var script_text: String?
            var is_Pinned: Bool?
            
            // Custom encoding to only include non-nil values
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                if let title = title {
                    try container.encode(title, forKey: .title)
                }
                
                if let scriptText = script_text {
                    try container.encode(scriptText, forKey: .script_text)
                }
                
                if let isPinned = is_Pinned {
                    try container.encode(isPinned, forKey: .is_Pinned)
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case title
                case script_text
                case is_Pinned
            }
        }
        
        // Build the update object with only provided values
        let updateData = ScriptUpdate(
            title: title,
            script_text: scriptText,
            is_Pinned: isPinned
        )
        
        // If all fields are nil, just fetch the script without updating
        if title == nil && scriptText == nil && isPinned == nil {
            print("No update data provided")
            return try await fetchScript(id: id)
        }
        
        do {
            let response = try await client
                .from("Script")
                .update(updateData)
                .eq("id", value: id.uuidString)
                .select()
                .single()
                .execute()
            
            // Convert response to Script object
            let script = try mapScriptFromResponse(responseData: response.data)
            print("Successfully updated script: \(script.title)")
            
            return script
        } catch {
            print("Error updating script \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Deletes a script from the database
    func deleteScript(id: UUID) async throws {
        print("Deleting script with ID: \(id.uuidString)")
        
        do {
            _ = try await client
                .from("Script")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            print("Successfully deleted script with ID: \(id.uuidString)")
        } catch {
            print("Error deleting script \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Maps the JSON response to a single Script object
    private func mapScriptFromResponse(responseData: Data) throws -> Script {
        struct ScriptResponse: Codable {
            let id: String
            let title: String?
            let script_text: String
            let is_Pinned: Bool?
            let created_at: String
            let user_id: String?
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(ScriptResponse.self, from: responseData)
            
            let dateFormatter = ISO8601DateFormatter()
            
            return Script(
                id: UUID(uuidString: response.id) ?? UUID(),
                title: response.title ?? "Untitled",
                scriptText: response.script_text,
                createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
                isPinned: response.is_Pinned ?? false
            )
        } catch {
            print("Failed to decode script response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    /// Maps the JSON response to an array of Script objects
    private func mapScriptsFromResponse(responseData: Data) throws -> [Script] {
        struct ScriptResponse: Codable {
            let id: String
            let title: String?
            let script_text: String
            let is_Pinned: Bool?
            let created_at: String
            let user_id: String?
        }
        
        let decoder = JSONDecoder()
        
        do {
            let responses = try decoder.decode([ScriptResponse].self, from: responseData)
            
            let dateFormatter = ISO8601DateFormatter()
            
            return responses.map { response in
                Script(
                    id: UUID(uuidString: response.id) ?? UUID(),
                    title: response.title ?? "Untitled",
                    scriptText: response.script_text,
                    createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
                    isPinned: response.is_Pinned ?? false
                )
            }
        } catch {
            print("Failed to decode scripts response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    // MARK: - Practice Session Methods
    
    /// Creates a new practice session in the database
    func createPracticeSession(scriptId: UUID, title: String) async throws -> PracticeSession {
        print("Creating new practice session for script: \(scriptId.uuidString)")
        
        // Create a properly structured type for inserting practice session
        struct PracticeSessionInsert: Encodable {
            let id: String
            let script_id: String
            let title: String
        }
        
        // Generate a UUID for the new session
        let sessionId = UUID()
        
        let sessionData = PracticeSessionInsert(
            id: sessionId.uuidString,
            script_id: scriptId.uuidString,
            title: title
        )
        
        do {
            let response = try await client
                .from("Practice_Session")
                .insert(sessionData)
                .select()
                .single()
                .execute()
            
            // Debug: print the JSON response
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Created practice session response: \(jsonString)")
            }
            
            // Map from Supabase response to Swift model
            let session = try mapPracticeSessionFromResponse(responseData: response.data)
            print("Practice session created successfully with ID: \(session.id)")
            
            return session
        } catch {
            print("Error creating practice session: \(error)")
            throw error
        }
    }
    
    /// Fetches all practice sessions for a specific script
    func fetchPracticeSessions(for scriptId: UUID) async throws -> [PracticeSession] {
        print("Fetching practice sessions for script: \(scriptId.uuidString)")
        
        do {
            let response = try await client
                .from("Practice_Session")
                .select("*")
                .eq("script_id", value: scriptId.uuidString)
                .order("created_at", ascending: false)
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched practice sessions response: \(jsonString)")
            }
            
            // Parse the JSON array into PracticeSession objects
            let sessions = try mapPracticeSessionsFromResponse(responseData: response.data)
            print("Fetched \(sessions.count) practice sessions successfully")
            
            return sessions
        } catch {
            print("Error fetching practice sessions: \(error)")
            throw error
        }
    }
    
    /// Fetches a specific practice session by ID
    func fetchPracticeSession(id: UUID) async throws -> PracticeSession {
        print("Fetching practice session with ID: \(id.uuidString)")
        
        do {
            let response = try await client
                .from("Practice_Session")
                .select("*")
                .eq("id", value: id.uuidString)
                .single()
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched single practice session response: \(jsonString)")
            }
            
            // Convert response to PracticeSession object
            let session = try mapPracticeSessionFromResponse(responseData: response.data)
            print("Successfully fetched practice session with title: \(session.title)")
            
            return session
        } catch {
            print("Error fetching practice session \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Updates an existing practice session
    func updatePracticeSession(id: UUID, title: String) async throws -> PracticeSession {
        print("Updating practice session with ID: \(id.uuidString)")
        
        // Create a properly structured type for updating practice session
        struct PracticeSessionUpdate: Encodable {
            let title: String
        }
        
        let updateData = PracticeSessionUpdate(title: title)
        
        do {
            let response = try await client
                .from("Practice_Session")
                .update(updateData)
                .eq("id", value: id.uuidString)
                .select()
                .single()
                .execute()
            
            // Convert response to PracticeSession object
            let session = try mapPracticeSessionFromResponse(responseData: response.data)
            print("Successfully updated practice session: \(session.title)")
            
            return session
        } catch {
            print("Error updating practice session \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Deletes a practice session from the database
    func deletePracticeSession(id: UUID) async throws {
        print("Deleting practice session with ID: \(id.uuidString)")
        
        do {
            _ = try await client
                .from("Practice_Session")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            print("Successfully deleted practice session with ID: \(id.uuidString)")
        } catch {
            print("Error deleting practice session \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Maps the JSON response to a single PracticeSession object
    private func mapPracticeSessionFromResponse(responseData: Data) throws -> PracticeSession {
        struct PracticeSessionResponse: Codable {
            let id: String
            let script_id: String
            let title: String
            let created_at: String
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(PracticeSessionResponse.self, from: responseData)
            
            let dateFormatter = ISO8601DateFormatter()
            
            return PracticeSession(
                id: UUID(uuidString: response.id) ?? UUID(),
                scriptId: UUID(uuidString: response.script_id) ?? UUID(),
                createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
                title: response.title
            )
        } catch {
            print("Failed to decode practice session response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    /// Maps the JSON response to an array of PracticeSession objects
    private func mapPracticeSessionsFromResponse(responseData: Data) throws -> [PracticeSession] {
        struct PracticeSessionResponse: Codable {
            let id: String
            let script_id: String
            let title: String
            let created_at: String
        }
        
        let decoder = JSONDecoder()
        
        do {
            let responses = try decoder.decode([PracticeSessionResponse].self, from: responseData)
            
            let dateFormatter = ISO8601DateFormatter()
            
            return responses.map { response in
                PracticeSession(
                    id: UUID(uuidString: response.id) ?? UUID(),
                    scriptId: UUID(uuidString: response.script_id) ?? UUID(),
                    createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
                    title: response.title
                )
            }
        } catch {
            print("Failed to decode practice sessions response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    // MARK: - Performance Report Methods
    
    /// Creates a new performance report in the database
    func createPerformanceReport(report: PerformanceReport) async throws -> UUID {
        print("Creating new performance report for session: \(report.sessionID.uuidString)")
        
        // First, check if the session exists
        let sessionExists = try await verifySessionExists(sessionId: report.sessionID)
        if !sessionExists {
            throw AuthError.unknown("Session with ID \(report.sessionID.uuidString) does not exist in the database")
        }
        
        // Try to fix the foreign key constraint
        _ = try? await fixForeignKeyConstraint()
        
        // First, check if the table exists and has the correct structure
        if let tableInfo = try? await checkPerformanceReportTable() {
            print("Performance_Report table structure: \(tableInfo)")
        }
        
        // Encode the filler words, missing words, and pronunciation errors to JSON
        let encoder = JSONEncoder()
        
        let fillerWordsData = try encoder.encode(report.fillerWords)
        let missingWordsData = try encoder.encode(report.missingWords)
        let pronunciationErrorsData = try encoder.encode(report.pronunciationErrors)
        
        guard let fillerWordsJson = String(data: fillerWordsData, encoding: .utf8),
              let missingWordsJson = String(data: missingWordsData, encoding: .utf8),
              let pronunciationErrorsJson = String(data: pronunciationErrorsData, encoding: .utf8) else {
            throw AuthError.unknown("Failed to encode report data to JSON")
        }
        
        // Create a properly structured type for inserting performance report
        struct PerformanceReportInsert: Encodable {
            let session_id: String
            let pace_interval: Double
            let video_url: String?
            let filler_words: String
            let missing_words: String
            let pronunciation_errors: String
            let duration: Double
            
            private enum CodingKeys: String, CodingKey {
                case session_id, pace_interval, video_url, filler_words, missing_words, pronunciation_errors, duration
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(session_id, forKey: .session_id)
                try container.encode(pace_interval, forKey: .pace_interval)
                try container.encodeIfPresent(video_url, forKey: .video_url)
                
                // Encode JSON strings as raw JSON
                try container.encode(filler_words, forKey: .filler_words)
                try container.encode(missing_words, forKey: .missing_words)
                try container.encode(pronunciation_errors, forKey: .pronunciation_errors)
                
                try container.encode(duration, forKey: .duration)
            }
        }
        
        let reportData = PerformanceReportInsert(
            session_id: report.sessionID.uuidString,
            pace_interval: Double(report.wordsPerMinute),
            video_url: report.videoURL?.absoluteString,
            filler_words: fillerWordsJson,
            missing_words: missingWordsJson,
            pronunciation_errors: pronunciationErrorsJson,
            duration: report.duration
        )
        
        do {
            print("Attempting to insert performance report into Supabase...")
            print("Report data: session_id=\(reportData.session_id), pace=\(reportData.pace_interval), duration=\(reportData.duration)")
            
            let response = try await client
                .from("Performance_Report")
                .insert(reportData)
                .select()
                .single()
                .execute()
            
            // Debug: print the JSON response
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Created performance report response: \(jsonString)")
            }
            
            // Extract the ID from the response
            struct ReportIDResponse: Codable {
                let id: String
            }
            
            let decoder = JSONDecoder()
            let idResponse = try decoder.decode(ReportIDResponse.self, from: response.data)
            let reportId = UUID(uuidString: idResponse.id) ?? UUID()
            
            print("Performance report created successfully with ID: \(reportId.uuidString)")
            
            return reportId
        } catch {
            print("Error creating performance report: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // If this is a PostgreSQL error with details, try to extract and print them
            if error.localizedDescription.contains("PostgreSQL error") {
                print("PostgreSQL error detected: \(error.localizedDescription)")
            }
            
            // Try to see if we can determine more about table structure or constraints
            print("Attempting to get table information for Performance_Report...")
            
            throw error
        }
    }
    
    /// Fetches a performance report for a specific practice session
    func fetchPerformanceReport(for sessionId: UUID) async throws -> PerformanceReport? {
        print("Fetching performance report for session: \(sessionId.uuidString)")
        
        do {
            let response = try await client
                .from("Performance_Report")
                .select("*")
                .eq("session_id", value: sessionId.uuidString)
                .single()
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched performance report response: \(jsonString)")
            }
            
            // Convert response to PerformanceReport object
            let report = try mapPerformanceReportFromResponse(responseData: response.data)
            print("Successfully fetched performance report for session: \(sessionId.uuidString)")
            
            return report
        } catch {
            // If no report is found, return nil instead of throwing an error
            // Check error description since we don't have direct access to the enum case
            if error.localizedDescription.contains("no rows returned") {
                print("No performance report found for session: \(sessionId.uuidString)")
                return nil
            }
            
            print("Error fetching performance report: \(error)")
            throw error
        }
    }
    
    /// Maps the JSON response to a PerformanceReport object
    private func mapPerformanceReportFromResponse(responseData: Data) throws -> PerformanceReport {
        // Print the raw response for debugging
        if let jsonString = String(data: responseData, encoding: .utf8) {
            print("Raw performance report JSON: \(jsonString)")
        }
        
        struct PerformanceReportResponse: Codable {
            let id: String
            let session_id: String
            let pace_interval: Double
            let video_url: String?
            let filler_words: String
            let missing_words: String
            let pronunciation_errors: String
            let duration: Double
            let created_at: String?  // Make this optional to handle cases where it doesn't exist
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(PerformanceReportResponse.self, from: responseData)
            
            // Decode the JSON strings back into arrays
            let fillerWords = try decoder.decode([SpeechAnalysisResult.FillerWord].self, from: Data(response.filler_words.utf8))
            let missingWords = try decoder.decode([SpeechAnalysisResult.MissingWord].self, from: Data(response.missing_words.utf8))
            let pronunciationErrors = try decoder.decode([SpeechAnalysisResult.PronunciationError].self, from: Data(response.pronunciation_errors.utf8))
            
            // Create a URL from the video URL string if one exists
            let videoURL = response.video_url != nil ? URL(string: response.video_url!) : nil
            
            return PerformanceReport(
                sessionID: UUID(uuidString: response.session_id) ?? UUID(),
                wordsPerMinute: Int(response.pace_interval),
                fillerWords: fillerWords,
                missingWords: missingWords,
                pronunciationErrors: pronunciationErrors,
                duration: response.duration,
                videoURL: videoURL
            )
        } catch {
            print("Failed to decode performance report response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    /// Fetches all performance reports for the current user
    func fetchAllPerformanceReports() async throws -> [PerformanceReport] {
        print("Fetching all performance reports for current user")
        
        guard let userId = currentUser?.id else {
            print("Cannot fetch performance reports: No user logged in")
            throw AuthError.userNotFound
        }
        
        do {
            // First get all practice sessions for the user to get their IDs
            let sessionsResponse = try await client
                .from("Practice_Session")
                .select("id")
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            struct SessionIDResponse: Codable {
                let id: String
            }
            
            let decoder = JSONDecoder()
            let sessionIDs = try decoder.decode([SessionIDResponse].self, from: sessionsResponse.data)
            
            if sessionIDs.isEmpty {
                print("No practice sessions found for user, returning empty reports array")
                return []
            }
            
            // Now fetch all performance reports that match these session IDs
            // We need to use in() filter with the session IDs
            let sessionIDStrings = sessionIDs.map { $0.id }
            
            let reportsResponse = try await client
                .from("Performance_Report")
                .select("*")
                .filter("session_id", operator: "in", value: #"("# + sessionIDStrings.joined(separator: ",") + #")"#)
                .execute()
            
            if let jsonString = String(data: reportsResponse.data, encoding: .utf8) {
                print("Fetched performance reports response: \(jsonString)")
            }
            
            // Parse the response data into an array of PerformanceReportResponse objects
            struct PerformanceReportListResponse: Codable {
                let id: String
                let session_id: String
                let pace_interval: Double
                let video_url: String?
                let filler_words: String
                let missing_words: String
                let pronunciation_errors: String
                let duration: Double
                let created_at: String?  // Make this optional to handle cases where it doesn't exist
            }
            
            let reportResponses = try decoder.decode([PerformanceReportListResponse].self, from: reportsResponse.data)
            
            // Map each response to a PerformanceReport object
            var reports: [PerformanceReport] = []
            
            for response in reportResponses {
                // Decode the JSON strings back into arrays
                let fillerWords = try decoder.decode([SpeechAnalysisResult.FillerWord].self, from: Data(response.filler_words.utf8))
                let missingWords = try decoder.decode([SpeechAnalysisResult.MissingWord].self, from: Data(response.missing_words.utf8))
                let pronunciationErrors = try decoder.decode([SpeechAnalysisResult.PronunciationError].self, from: Data(response.pronunciation_errors.utf8))
                
                // Create a URL from the video URL string if one exists
                let videoURL = response.video_url != nil ? URL(string: response.video_url!) : nil
                
                let report = PerformanceReport(
                    sessionID: UUID(uuidString: response.session_id) ?? UUID(),
                    wordsPerMinute: Int(response.pace_interval),
                    fillerWords: fillerWords,
                    missingWords: missingWords,
                    pronunciationErrors: pronunciationErrors,
                    duration: response.duration,
                    videoURL: videoURL
                )
                
                reports.append(report)
            }
            
            print("Successfully fetched \(reports.count) performance reports")
            return reports
        } catch {
            print("Error fetching performance reports: \(error)")
            throw error
        }
    }
    
    // MARK: - QnA Session Methods
    
    /// Creates a new QnA session in the database
    func createQnASession(scriptId: UUID, title: String) async throws -> QnASession {
        print("Creating new QnA session for script: \(scriptId.uuidString)")
        
        // Create a properly structured type for inserting QnA session
        struct QnASessionInsert: Encodable {
            let script_id: String
            let title: String
        }
        
        let sessionData = QnASessionInsert(
            script_id: scriptId.uuidString,
            title: title
        )
        
        do {
            let response = try await client
                .from("Qna_Sessions")
                .insert(sessionData)
                .select()
                .single()
                .execute()
            
            // Debug: print the JSON response
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Created QnA session response: \(jsonString)")
            }
            
            // Map from Supabase response to Swift model
            let session = try mapQnASessionFromResponse(responseData: response.data)
            print("QnA session created successfully with ID: \(session.id)")
            
            return session
        } catch {
            print("Error creating QnA session: \(error)")
            throw error
        }
    }
    
    /// Fetches all QnA sessions for a specific script
    func fetchQnASessions(for scriptId: UUID) async throws -> [QnASession] {
        print("Fetching QnA sessions for script: \(scriptId.uuidString)")
        
        do {
            let response = try await client
                .from("Qna_Sessions")
                .select("*")
                .eq("script_id", value: scriptId.uuidString)
                .order("created_at", ascending: false)
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched QnA sessions response: \(jsonString)")
            }
            
            // Parse the JSON array into QnASession objects
            let sessions = try mapQnASessionsFromResponse(responseData: response.data)
            print("Fetched \(sessions.count) QnA sessions successfully")
            
            return sessions
        } catch {
            print("Error fetching QnA sessions: \(error)")
            throw error
        }
    }
    
    /// Fetches a specific QnA session by ID
    func fetchQnASession(id: UUID) async throws -> QnASession {
        print("Fetching QnA session with ID: \(id.uuidString)")
        
        do {
            let response = try await client
                .from("Qna_Sessions")
                .select("*")
                .eq("id", value: id.uuidString)
                .single()
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched single QnA session response: \(jsonString)")
            }
            
            // Convert response to QnASession object
            let session = try mapQnASessionFromResponse(responseData: response.data)
            print("Successfully fetched QnA session with title: \(session.title)")
            
            return session
        } catch {
            print("Error fetching QnA session \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Deletes a QnA session from the database
    func deleteQnASession(id: UUID) async throws {
        print("Deleting QnA session with ID: \(id.uuidString)")
        
        do {
            _ = try await client
                .from("Qna_Sessions")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            print("Successfully deleted QnA session with ID: \(id.uuidString)")
        } catch {
            print("Error deleting QnA session \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Maps the JSON response to a single QnASession object
    private func mapQnASessionFromResponse(responseData: Data) throws -> QnASession {
        struct QnASessionResponse: Codable {
            let id: String
            let script_id: String
            let title: String
            let created_at: String
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(QnASessionResponse.self, from: responseData)
            
            let dateFormatter = ISO8601DateFormatter()
            
            return QnASession(
                id: UUID(uuidString: response.id) ?? UUID(),
                scriptId: UUID(uuidString: response.script_id) ?? UUID(),
                createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
                title: response.title
            )
        } catch {
            print("Failed to decode QnA session response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    /// Maps the JSON response to an array of QnASession objects
    private func mapQnASessionsFromResponse(responseData: Data) throws -> [QnASession] {
        struct QnASessionResponse: Codable {
            let id: String
            let script_id: String
            let title: String
            let created_at: String
        }
        
        let decoder = JSONDecoder()
        
        do {
            let responses = try decoder.decode([QnASessionResponse].self, from: responseData)
            
            let dateFormatter = ISO8601DateFormatter()
            
            return responses.map { response in
                QnASession(
                    id: UUID(uuidString: response.id) ?? UUID(),
                    scriptId: UUID(uuidString: response.script_id) ?? UUID(),
                    createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
                    title: response.title
                )
            }
        } catch {
            print("Failed to decode QnA sessions response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    // MARK: - QnA Question Methods
    
    /// Creates a new QnA question in the database
    func createQnAQuestion(
        qnaSessionId: UUID,
        questionText: String,
        suggestedAnswer: String
    ) async throws -> QnAQuestion {
        print("Creating new QnA question for session: \(qnaSessionId.uuidString)")
        
        // Create a properly structured type for inserting QnA question
        struct QnAQuestionInsert: Encodable {
            let qna_sessions_id: String
            let question_text: String
            let suggested_answer: String
            let time: Int
        }
        
        let questionData = QnAQuestionInsert(
            qna_sessions_id: qnaSessionId.uuidString,
            question_text: questionText,
            suggested_answer: suggestedAnswer,
            time: 0  // Default value, will be updated when answered
        )
        
        do {
            let response = try await client
                .from("Qna_Question")
                .insert(questionData)
                .select()
                .single()
                .execute()
            
            // Debug: print the JSON response
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Created QnA question response: \(jsonString)")
            }
            
            // Map from Supabase response to Swift model
            let question = try mapQnAQuestionFromResponse(responseData: response.data)
            print("QnA question created successfully with ID: \(question.id)")
            
            return question
        } catch {
            print("Error creating QnA question: \(error)")
            throw error
        }
    }
    
    /// Fetches all QnA questions for a specific QnA session
    func fetchQnAQuestions(for qnaSessionId: UUID) async throws -> [QnAQuestion] {
        print("Fetching QnA questions for session: \(qnaSessionId.uuidString)")
        
        do {
            let response = try await client
                .from("Qna_Question")
                .select("*")
                .eq("qna_sessions_id", value: qnaSessionId.uuidString)
                .order("created_at", ascending: true)
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Fetched QnA questions response: \(jsonString)")
            }
            
            // Parse the JSON array into QnAQuestion objects
            let questions = try mapQnAQuestionsFromResponse(responseData: response.data)
            print("Fetched \(questions.count) QnA questions successfully")
            
            return questions
        } catch {
            print("Error fetching QnA questions: \(error)")
            throw error
        }
    }
    
    /// Updates a QnA question with the user's answer and time taken
    func updateQnAQuestion(
        id: UUID,
        userAnswer: String,
        timeTaken: TimeInterval
    ) async throws -> QnAQuestion {
        print("Updating QnA question with ID: \(id.uuidString)")
        
        // Create a properly structured type for updating QnA question
        struct QnAQuestionUpdate: Encodable {
            let user_answer: String
            let time: Int
        }
        
        let updateData = QnAQuestionUpdate(
            user_answer: userAnswer,
            time: Int(timeTaken)
        )
        
        do {
            let response = try await client
                .from("Qna_Question")
                .update(updateData)
                .eq("id", value: id.uuidString)
                .select()
                .single()
                .execute()
            
            // Convert response to QnAQuestion object
            let question = try mapQnAQuestionFromResponse(responseData: response.data)
            print("Successfully updated QnA question with ID: \(question.id)")
            
            return question
        } catch {
            print("Error updating QnA question \(id.uuidString): \(error)")
            throw error
        }
    }
    
    /// Maps the JSON response to a single QnAQuestion object
    private func mapQnAQuestionFromResponse(responseData: Data) throws -> QnAQuestion {
        struct QnAQuestionResponse: Codable {
            let id: String
            let qna_sessions_id: String
            let question_text: String
            let user_answer: String
            let suggested_answer: String
            let time: Int
            let created_at: String
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(QnAQuestionResponse.self, from: responseData)
            
            return QnAQuestion(
                id: UUID(uuidString: response.id) ?? UUID(),
                qna_session_Id: UUID(uuidString: response.qna_sessions_id) ?? UUID(),
                questionText: response.question_text,
                userAnswer: response.user_answer,
                suggestedAnswer: response.suggested_answer,
                timeTaken: TimeInterval(response.time)
            )
        } catch {
            print("Failed to decode QnA question response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    /// Maps the JSON response to an array of QnAQuestion objects
    private func mapQnAQuestionsFromResponse(responseData: Data) throws -> [QnAQuestion] {
        struct QnAQuestionResponse: Codable {
            let id: String
            let qna_sessions_id: String
            let question_text: String
            let user_answer: String
            let suggested_answer: String
            let time: Int
            let created_at: String
        }
        
        let decoder = JSONDecoder()
        
        do {
            let responses = try decoder.decode([QnAQuestionResponse].self, from: responseData)
            
            return responses.map { response in
                QnAQuestion(
                    id: UUID(uuidString: response.id) ?? UUID(),
                    qna_session_Id: UUID(uuidString: response.qna_sessions_id) ?? UUID(),
                    questionText: response.question_text,
                    userAnswer: response.user_answer,
                    suggestedAnswer: response.suggested_answer,
                    timeTaken: TimeInterval(response.time)
                )
            }
        } catch {
            print("Failed to decode QnA questions response: \(error)")
            if let dataString = String(data: responseData, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            throw error
        }
    }
    
    // MARK: - Debugging Helpers
    
    /// Check if the Performance_Report table exists and has the correct structure
    private func checkPerformanceReportTable() async throws -> String {
        do {
            // Query the information schema to get table information
            let response = try await client
                .rpc("get_table_info", params: ["table_name": "Performance_Report"])
                .execute()
            
            if let jsonString = String(data: response.data, encoding: .utf8) {
                return jsonString
            }
            return "No table info available"
        } catch {
            print("Error checking Performance_Report table: \(error)")
            
            // Try to create the table if it doesn't exist
            do {
                let createTableResponse = try await client
                    .rpc("create_performance_report_table")
                    .execute()
                
                if let jsonString = String(data: createTableResponse.data, encoding: .utf8) {
                    return "Table created: \(jsonString)"
                }
                return "Table created but no response data"
            } catch {
                return "Failed to check or create table: \(error.localizedDescription)"
            }
        }
    }
    
    /// Verify that session exists before trying to reference it
    private func verifySessionExists(sessionId: UUID) async throws -> Bool {
        print("Verifying session existence for ID: \(sessionId.uuidString)")
        
        // Retry logic with exponential backoff
        let maxRetries = 3
        var delay: UInt64 = 500_000_000 // 0.5 seconds
        
        for attempt in 1...maxRetries {
            do {
                let response = try await client
                    .from("Practice_Session")
                    .select("*")
                    .eq("id", value: sessionId.uuidString)
                    .single()
                    .execute()
                
                // If the response contains data, the session exists
                if let jsonString = String(data: response.data, encoding: .utf8),
                   !jsonString.isEmpty && jsonString != "null" {
                    print("✅ Session exists (attempt \(attempt)): \(jsonString)")
                    return true
                } else {
                    print("⚠️ Session with ID \(sessionId.uuidString) not found on attempt \(attempt)")
                    
                    if attempt < maxRetries {
                        print("Waiting \(delay/1_000_000_000) seconds before retry...")
                        try await Task.sleep(nanoseconds: delay)
                        delay *= 2 // Exponential backoff
                    }
                }
            } catch {
                print("Error verifying session existence (attempt \(attempt)): \(error)")
                
                if attempt < maxRetries {
                    print("Waiting \(delay/1_000_000_000) seconds before retry...")
                    try await Task.sleep(nanoseconds: delay)
                    delay *= 2 // Exponential backoff
                }
            }
        }
        
        print("❌ Session with ID \(sessionId.uuidString) not found after \(maxRetries) attempts")
        return false
    }
    
    /// Fix the foreign key constraint if it has issues
    public func fixForeignKeyConstraint() async throws -> Bool {
        do {
            print("Attempting to fix foreign key constraint...")
            
            // First, check the current constraints
            let checkSQL = """
            SELECT conname FROM pg_constraint
            WHERE conrelid = 'Performance_Report'::regclass::oid
            AND contype = 'f';
            """
            
            let checkResponse = try await client.database.rpc("query", params: ["query": checkSQL]).execute()
            print("Current constraints: \(String(data: checkResponse.data, encoding: .utf8) ?? "No constraints found")")
            
            // SQL to fix the constraint
            let sql = """
            -- Drop the incorrect constraint if it exists
            ALTER TABLE "Performance_Report" DROP CONSTRAINT IF EXISTS "Performace_Report_session_id_fkey";
            
            -- Also try with other potential misspellings
            ALTER TABLE "Performance_Report" DROP CONSTRAINT IF EXISTS "Performance_Report_session_id_fkey";
            
            -- Create the correct constraint
            ALTER TABLE "Performance_Report" ADD CONSTRAINT "Performance_Report_session_id_fkey" 
            FOREIGN KEY (session_id) REFERENCES "Practice_Session"(id) ON DELETE CASCADE;
            """
            
            let response = try await client.database.rpc("query", params: ["query": sql]).execute()
            print("Foreign key constraint SQL execution result: \(String(data: response.data, encoding: .utf8) ?? "No response")")
            
            // Verify the constraint was fixed correctly
            let verifySQL = """
            SELECT conname FROM pg_constraint
            WHERE conrelid = 'Performance_Report'::regclass::oid
            AND contype = 'f';
            """
            
            let verifyResponse = try await client.database.rpc("query", params: ["query": verifySQL]).execute()
            let verifyResult = String(data: verifyResponse.data, encoding: .utf8) ?? "No response"
            print("Constraint verification after fix: \(verifyResult)")
            
            // If verification shows the constraint is still not correct, return false
            if !verifyResult.contains("Performance_Report_session_id_fkey") {
                print("WARNING: Foreign key constraint still not correctly fixed after attempt")
                return false
            }
            
            print("Foreign key constraint successfully fixed")
            return true
        } catch {
            print("Error fixing foreign key constraint: \(error)")
            print("Error details: \(error.localizedDescription)")
            return false
        }
    }
}
