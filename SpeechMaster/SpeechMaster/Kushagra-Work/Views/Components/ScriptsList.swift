import SwiftUI

struct ScriptsList: View {
    let scripts: [Script]
    @ObservedObject var viewModel: HomeViewModel
    private let dataSource = DataController.shared
    
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
}

