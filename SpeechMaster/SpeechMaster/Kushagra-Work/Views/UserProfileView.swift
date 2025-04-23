import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Remove didSet handlers - we'll handle updates manually
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingLogoutAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var notificationsEnabled = true
    @State private var emailNotificationsEnabled = true
    @State private var userName = ""
    @State private var userEmail = ""
    @State private var showingImagePicker = false
    @State private var selectedProfileImage: UIImage?
    @State private var showingSuccess = false
    
    // Track whether preferences have been modified
    @State private var preferencesModified = false
    
    // Keep initial values to detect changes
    @State private var initialDarkMode = false
    @State private var initialNotifications = true
    @State private var initialEmailNotifications = true
    
    private let supabaseManager = SupabaseManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let selectedImage = selectedProfileImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    .overlay(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))
                            )
                            .offset(x: 35, y: 35)
                    )
                    
                    Text(userName).font(.title).fontWeight(.bold)
                    Text(userEmail).font(.caption)
                }
                .padding(.init(top: 50, leading: 0, bottom: 20, trailing: 0))
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
                
                List {
                    Section("App Settings") {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .onChange(of: isDarkMode) { _ in
                                preferencesModified = true
                            }
                        
                        Toggle("Notifications", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { _ in
                                preferencesModified = true
                            }
                        
                        Toggle("Email Notifications", isOn: $emailNotificationsEnabled)
                            .onChange(of: emailNotificationsEnabled) { _ in
                                preferencesModified = true
                            }
                        
                        NavigationLink(destination: Text("Language Settings")) {
                            Label("Language", systemImage: "globe")
                        }
                    }
                    
                    if preferencesModified {
                        Section {
                            Button("Save Changes") {
                                updateUserPreferences()
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    Section("Scripts") {
                        NavigationLink(destination: Text("Saved Scripts")) {
                            Label("Saved Scripts", systemImage: "doc.text")
                        }
                        
                        NavigationLink(destination: Text("Script Templates")) {
                            Label("Templates", systemImage: "doc.on.doc")
                        }
                    }
                    
                    Section("Support") {
                        NavigationLink(destination: Text("Help Center")) {
                            Label("Help Center", systemImage: "questionmark.circle")
                        }
                        
                        NavigationLink(destination: Text("Privacy Policy")) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                        }
                        
                        NavigationLink(destination: Text("Terms of Service")) {
                            Label("Terms of Service", systemImage: "doc.text")
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showingLogoutAlert = true
                        } label: {
                            if isLoading {
                                HStack {
                                    Text("Logging out...")
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                }
                            } else {
                                Label("Log Out", systemImage: "arrow.right.square")
                            }
                        }
                        .disabled(isLoading)
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedProfileImage) {
                    saveProfileImageLocally()
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) { 
                    // Reset the modified flag after successful save
                    preferencesModified = false
                }
            } message: {
                Text("Profile updated successfully!")
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    private func loadUserData() {
        isLoading = true
        
        Task {
            do {
                if let user = supabaseManager.currentUser {
                    await MainActor.run {
                        userName = user.name
                        userEmail = user.email
                        
                        // Store both current and initial values
                        isDarkMode = user.preferences.isDarkMode
                        notificationsEnabled = user.preferences.notificationsEnabled
                        emailNotificationsEnabled = user.preferences.emailNotificationsEnabled
                        
                        // Store initial values to detect changes
                        initialDarkMode = isDarkMode
                        initialNotifications = notificationsEnabled
                        initialEmailNotifications = emailNotificationsEnabled
                        
                        // Reset the modified flag
                        preferencesModified = false
                        
                        // Update the HomeViewModel as well
                        viewModel.userName = user.name
                    }
                    
                    // Load profile image from local storage
                    if let userId = user.id.uuidString as String? {
                        await MainActor.run {
                            selectedProfileImage = loadProfileImage(forKey: userId)
                            isLoading = false
                        }
                    } else {
                        await MainActor.run {
                            isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        showError(message: "Unable to load user data")
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    showError(message: "Error loading user data: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    private func updateUserPreferences() {
        isLoading = true
        
        Task {
            do {
                let preferences = User.UserPreferences(
                    isDarkMode: isDarkMode,
                    notificationsEnabled: notificationsEnabled,
                    emailNotificationsEnabled: emailNotificationsEnabled
                )
                
                try await supabaseManager.updateUserPreferences(preferences: preferences)
                
                await MainActor.run {
                    isLoading = false
                    showingSuccess = true
                    
                    // Update initial values after successful save
                    initialDarkMode = isDarkMode
                    initialNotifications = notificationsEnabled
                    initialEmailNotifications = emailNotificationsEnabled
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError(message: "Failed to update preferences: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func signOut() {
        isLoading = true
        
        Task {
            do {
                try await supabaseManager.signOut()
                
                await MainActor.run {
                    // Update the HomeViewModel
                    viewModel.isLoggedIn = false
                    viewModel.userName = ""
                    
                    // Clear user defaults
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.synchronize()
                    
                    // Post notification that user logged out
                    NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
                    print("Posted UserLoggedOut notification")
                    
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    showError(message: "Error signing out: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Local Image Storage Methods
    
    private func saveProfileImageLocally() {
        guard let image = selectedProfileImage, 
              let userId = supabaseManager.currentUser?.id.uuidString,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            showError(message: "Failed to process image")
            return
        }
        
        isLoading = true
        
        // Save image to file system
        if saveImageToFileSystem(imageData: imageData, forKey: userId) {
            // Also update the Supabase record with a flag that indicates local image storage
            Task {
                do {
                    // Instead of uploading to Supabase, just update the user's preferences
                    // This allows us to know a profile image exists locally
                    let preferences = User.UserPreferences(
                        isDarkMode: isDarkMode,
                        notificationsEnabled: notificationsEnabled,
                        emailNotificationsEnabled: emailNotificationsEnabled
                    )
                    
                    try await supabaseManager.updateUserPreferences(preferences: preferences)
                    
                    await MainActor.run {
                        isLoading = false
                        showingSuccess = true
                    }
                } catch {
                    await MainActor.run {
                        // Even if Supabase update fails, the image is still saved locally
                        isLoading = false
                        showingSuccess = true
                    }
                }
            }
        } else {
            showError(message: "Failed to save image to device")
            isLoading = false
        }
    }
    
    private func saveImageToFileSystem(imageData: Data, forKey key: String) -> Bool {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("profileImage_\(key).jpg")
        
        do {
            try imageData.write(to: fileURL)
            print("Image saved successfully at: \(fileURL)")
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }
    
    private func loadProfileImage(forKey key: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("profileImage_\(key).jpg")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Error loading image: \(error)")
                return nil
            }
        }
        
        return nil
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// Image picker component
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var onSelect: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        guard let self = self, let image = image as? UIImage else { return }
                        self.parent.selectedImage = image
                        self.parent.onSelect()
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfileView(viewModel: HomeViewModel.shared)
}

