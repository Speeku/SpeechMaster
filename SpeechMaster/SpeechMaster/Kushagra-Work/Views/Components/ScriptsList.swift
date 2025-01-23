import SwiftUI

struct ScriptsList: View {
    let scripts: [Script]
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            ForEach(scripts) { script in
                NavigationLink(destination: StoryboardView()) {
                    ScriptRow(script: script, viewModel: viewModel)
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
