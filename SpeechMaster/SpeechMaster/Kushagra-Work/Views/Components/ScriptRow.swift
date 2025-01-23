import SwiftUI

struct StoryboardView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        // Get reference to your storyboard
        let storyboard = UIStoryboard(name: "ProgressSession", bundle: nil)
        
        // Instantiate the desired view controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "ScriptDetailedSection")
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct ScriptRow: View {
    let script: Script
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingInfoSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(script.title)
                        .font(.headline)
                    if script.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                Text(script.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                showingInfoSheet = true
            }) {
                Label("Info", systemImage: "info.circle")
            }
            
            Button(action: {
                withAnimation {
                    viewModel.togglePin(for: script)
                }
            }) {
                Label(script.isPinned ? "Unpin" : "Pin to Top", 
                      systemImage: script.isPinned ? "pin.slash" : "pin")
            }
            
            Button(role: .destructive, action: {
                withAnimation {
                    viewModel.deleteScript(script)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingInfoSheet) {
            ScriptInfoView(script: script)
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
        
    }
}

#Preview {
    NavigationView {
        ScriptRow(
            script: Script(title: "Sample Script", date: Date(), isPinned: true),
            viewModel: HomeViewModel()
        )
    }
}
