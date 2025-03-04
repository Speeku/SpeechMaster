import SwiftUI
import UIKit

struct StoryboardView: UIViewControllerRepresentable {
    let script: Script
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Get reference to your storyboard
        let storyboard = UIStoryboard(name: "ProgressSession", bundle: nil)
        
        // Instantiate the desired view controller
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ScriptDetailedSection") as? ProgressViewController
        else {
            fatalError("Could not instantiate ViewController")
        }
        
        // Set all required properties
        viewController.navigationItem.title = script.title
        viewController.scriptTitle = script.title
        viewController.scriptText = script.scriptText
        viewController.scriptId = script.id  // Pass the script ID
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let VC = uiViewController as? ProgressViewController {
            VC.scriptTitle = script.title
            VC.textView.text = script.scriptText
            VC.navigationItem.title = script.title
            VC.scriptText = script.scriptText
            VC.scriptId = script.id  // Update script ID if view controller is updated
        }
        // Update the view controller if needed
    }
}

struct ScriptRow: View {
    let script: Script
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingInfoSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: StoryboardView(script: script)) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(script.title)
                            .font(.headline)
                            .foregroundColor(.black)
                        if script.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    Text(script.createdAt, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            
            // Practice Button
            Button {
                viewModel.currentScriptID = script.id
                viewModel.uploadedScriptText = script.scriptText
                viewModel.navigateToPiyushScreen = true
            } label: {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 22, weight: .semibold))
            }
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
            
            Button(action: {
                ShareUtility.shareScriptAsPDF(script)
            }) {
                Label("Share as PDF", systemImage: "square.and.arrow.up")
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
        .buttonStyle(.plain)
    }
}
#Preview {
}
