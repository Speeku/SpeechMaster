import SwiftUI

struct ScriptsList: View {
    let scripts: [Script]
    @ObservedObject var viewModel: HomeViewModel
    //private let dataSource = DataController.shared
    
    var recentScripts: [Script] {
        // Sort scripts by pinned status first, then by date
        let sortedScripts = scripts.sorted { (script1, script2) in
            if script1.isPinned && !script2.isPinned {
                return true
            }
            if !script1.isPinned && script2.isPinned {
                return false
            }
            return script1.createdAt > script2.createdAt
        }
        return Array(sortedScripts.prefix(5))
    }
    
    var body: some View {
        VStack {
            ForEach(recentScripts) { script in
                NavigationLink(destination: StoryboardView(script: script)) {
                    ScriptRow(script: script, viewModel: viewModel)
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
                                Label(script.isPinned ? "Unpin" : "Pin", 
                                      systemImage: script.isPinned ? "pin.slash" : "pin")
                            }
                            .tint(.blue)
                            
                            Button {
                                ShareUtility.shareScriptAsPDF(script)
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .tint(.green)
                        }
                        .onLongPressGesture {
                            // Show action sheet for sharing
                            showShareOptions(for: script)
                        }
                }
                if script.id != recentScripts.last?.id {
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // Function to show share options
    private func showShareOptions(for script: Script) {
        let alert = UIAlertController(
            title: script.title,
            message: "What would you like to do?",
            preferredStyle: .actionSheet
        )
        
        // Add share as PDF option
        alert.addAction(UIAlertAction(title: "Share as PDF", style: .default) { _ in
            ShareUtility.shareScriptAsPDF(script)
        })
        
        // Add practice option
        alert.addAction(UIAlertAction(title: "Practice Script", style: .default) { _ in
            viewModel.currentScriptID = script.id
            viewModel.uploadedScriptText = script.scriptText
            viewModel.navigateToPiyushScreen = true
        })
        
        // Add cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            // For iPad, we need to set the sourceView and sourceRect to avoid crash
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = rootViewController.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, 
                                                    y: UIScreen.main.bounds.height / 2, 
                                                    width: 0, 
                                                    height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            rootViewController.present(alert, animated: true)
        }
    }
}

