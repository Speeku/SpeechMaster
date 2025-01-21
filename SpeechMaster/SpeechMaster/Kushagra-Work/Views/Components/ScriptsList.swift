import SwiftUI

struct ScriptsList: View {
    let scripts: [Script]
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(scripts) { script in
                NavigationLink(destination: StoryboardView()) {
                    ScriptRow(script: script, viewModel: viewModel)
                }
                .buttonStyle(.plain) // This ensures swipe actions work properly
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteScript(script)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        withAnimation {
                            viewModel.togglePin(for: script)
                        }
                    } label: {
                        if script.isPinned {
                            Label("Unpin", systemImage: "pin.slash")
                        } else {
                            Label("Pin", systemImage: "pin")
                        }
                    }
                    .tint(.blue)
                }
                
                if script.id != scripts.last?.id {
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationView {
        ScriptsList(
            scripts: [
                Script(title: "Sample Script 1", date: Date(), isPinned: true),
                Script(title: "Sample Script 2", date: Date().addingTimeInterval(-86400), isPinned: false)
            ],
            viewModel: HomeViewModel()
        )
        .padding()
    }
}
