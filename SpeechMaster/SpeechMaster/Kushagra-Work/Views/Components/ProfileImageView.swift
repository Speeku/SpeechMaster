import SwiftUI

struct ProfileImageView: View {
    let userId: String
    let imageURL: String?
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    private let supabaseManager = SupabaseManager.shared
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .frame(width: 38, height: 38)
            } else if let displayImage = image {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loadProfileImage()
        }
    }
    
    private func loadProfileImage() {
        // First try to load from local storage for faster display
        if !userId.isEmpty {
            loadLocalImage()
        }
        
        // Then try to load from Supabase if URL available
        if let imageURL = imageURL, !imageURL.isEmpty {
            loadSupabaseImage(path: imageURL)
        }
    }
    
    private func loadLocalImage() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("profileImage_\(userId).jpg")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                self.image = UIImage(data: imageData)
            } catch {
                print("Error loading local image: \(error)")
            }
        }
    }
    
    private func loadSupabaseImage(path: String) {
        isLoading = true
        
        Task {
            do {
                // Get a signed URL for the image
                if let url = try await supabaseManager.getProfileImageURL(path: path) {
                    // Download the image data
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    // Update the UI
                    await MainActor.run {
                        if let downloadedImage = UIImage(data: data) {
                            self.image = downloadedImage
                            
                            // Also save to local storage for caching
                            saveImageLocally(imageData: data)
                        }
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } catch {
                print("Error downloading profile image: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func saveImageLocally(imageData: Data) {
        guard !userId.isEmpty else { return }
        
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("profileImage_\(userId).jpg")
        
        do {
            try imageData.write(to: fileURL)
            print("Image cached successfully")
        } catch {
            print("Error caching image: \(error)")
        }
    }
} 
