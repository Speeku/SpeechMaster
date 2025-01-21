import SwiftUI

struct ScriptCreationView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scriptText = ""
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationView {
            TextEditor(text: $scriptText)
                .padding()
                .background(Color(.systemBackground))
                .navigationTitle("Create Script")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewModel.uploadedScriptText = scriptText
                            viewModel.navigateToPiyushScreen = true
                            dismiss()
                        }
                        .disabled(scriptText.isEmpty)
                    }
                }
        }
    }
}

#Preview {
    ScriptCreationView(viewModel: HomeViewModel())
} 