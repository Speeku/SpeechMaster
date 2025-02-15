import SwiftUI

struct ScriptInfoView: View {
    let script: Script
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Details") {
                    InfoRow(title: "Title", value: script.title)
                    InfoRow(title: "Created", value: script.createdAt.formatted(date: .long, time: .shortened))
                    InfoRow(title: "Size", value: "2.5 MB") // Hardcoded for now
                }
            }
            .navigationTitle("Script Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}

