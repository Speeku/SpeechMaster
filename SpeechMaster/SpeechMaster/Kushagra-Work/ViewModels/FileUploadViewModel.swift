import SwiftUI
import UniformTypeIdentifiers

class FileUploadViewModel: ObservableObject {
    @Published var showingFilePicker = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var uploadedScriptText = ""
    @Published var navigateToPiyushScreen = false
    
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
                alertMessage = "File uploaded successfully"
                showingAlert = true
                navigateToPiyushScreen = true
            } catch {
                alertMessage = "Error reading file: \(error.localizedDescription)"
                showingAlert = true
            }
            
        case .failure(let error):
            alertMessage = "Error selecting file: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    func getSupportedTypes() -> [UTType] {
        [.plainText]
    }
} 
