import Foundation
import Supabase
import Combine

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // Current user data
    @Published var currentUser: User?
    
    private let supabaseUrl = "https://zvzudspxufrliprownhr.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2enVkc3B4dWZybGlwcm93bmhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk3MzM2MjEsImV4cCI6MjA1NTMwOTYyMX0.5vXROUiBYj1vYkkWHgX-mCrmFAg5-O_rWskXGFwcuwM"
    
    let client: SupabaseClient
    
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
            .from("profile_images")
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
            .from("profile_images")
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
            .from("profile_images")
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
                .select()
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
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
            
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
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(ScriptResponse.self, from: responseData)
        
        let dateFormatter = ISO8601DateFormatter()
        
        return Script(
            id: UUID(uuidString: response.id) ?? UUID(),
            title: response.title ?? "Untitled",
            scriptText: response.script_text,
            createdAt: dateFormatter.date(from: response.created_at) ?? Date(),
            isPinned: response.is_Pinned ?? false
        )
    }
    
    /// Maps the JSON response to an array of Script objects
    private func mapScriptsFromResponse(responseData: Data) throws -> [Script] {
        struct ScriptResponse: Codable {
            let id: String
            let title: String?
            let script_text: String
            let is_Pinned: Bool?
            let created_at: String
        }
        
        let decoder = JSONDecoder()
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
    }
} 
