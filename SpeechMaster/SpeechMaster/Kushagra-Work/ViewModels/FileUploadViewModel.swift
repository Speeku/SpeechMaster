import SwiftUI
import UniformTypeIdentifiers

class FileUploadViewModel: ObservableObject {
    @Published var showingFilePicker = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var uploadedScriptText = ""
    @Published var showingNamePrompt = false
    @Published var scriptName = ""
    
    private let supabaseManager = SupabaseManager.shared
    
    func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                alertMessage = "Permission denied to access the file"
                showingAlert = true
                return
            }
            
            defer {
                // Make sure to release the security-scoped resource when finished
                url.stopAccessingSecurityScopedResource()
            }
            
            // Check if file is plaintext
            guard url.pathExtension.lowercased() == "txt" else {
                alertMessage = "Please Upload a correct file"
                showingAlert = true
                return
            }
            
            do {
                uploadedScriptText = try String(contentsOf: url, encoding: .utf8)
                
                // Get the file name without extension to use as script title
                let defaultName = url.deletingPathExtension().lastPathComponent
                scriptName = defaultName
                
                // Ask for script name
                showingNamePrompt = true
            } catch {
                alertMessage = "Error reading file: \(error.localizedDescription)"
                showingAlert = true
            }
            
        case .failure(let error):
            alertMessage = "Error selecting file: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    func saveScriptToSupabase() {
        guard !uploadedScriptText.isEmpty else {
            alertMessage = "Cannot save empty script"
            showingAlert = true
            return
        }
        
        // Create a trimmed name or use default
        let finalName = scriptName.trimmingCharacters(in: .whitespacesAndNewlines)
        let scriptTitle = finalName.isEmpty ? "Uploaded Script" : finalName
        
        // Create a new script locally
        let newScript = Script(
            id: UUID(),
            title: scriptTitle,
            scriptText: uploadedScriptText,
            createdAt: Date(),
            isPinned: false
        )
        
        // Save to Supabase
        HomeViewModel.shared.addScript(newScript)
        
        // Set for navigation and practice
        HomeViewModel.shared.uploadedScriptText = uploadedScriptText
        HomeViewModel.shared.currentScriptID = newScript.id
        
        // Show success message
        alertMessage = "Script saved successfully"
        showingAlert = true
        
        // Navigate to practice screen
        HomeViewModel.shared.navigateToPiyushScreen = true
    }
    
    func getSupportedTypes() -> [UTType] {
        [.plainText]
    }
} 
