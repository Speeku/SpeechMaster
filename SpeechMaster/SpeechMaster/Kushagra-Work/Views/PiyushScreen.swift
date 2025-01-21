import SwiftUI

struct PiyushScreen: View {
    let scriptText: String
    
    var body: some View {
        ScrollView {
            Text(scriptText)
                .padding()
        }
        .navigationTitle("Uploaded Script")
    }
}

#Preview {
    PiyushScreen(scriptText: "Sample script text for preview")
} 