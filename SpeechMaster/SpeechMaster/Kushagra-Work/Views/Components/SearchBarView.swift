import SwiftUI
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search Script", text: $searchText)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            Image(systemName: "mic.fill")
                .foregroundColor(.gray)
        }
        .frame(width: .infinity,height : 10)
        .padding()
        .background(Color(.white))
        .cornerRadius(25)
        .padding(.horizontal)
    }
} 
#Preview {
    @Previewable @StateObject var viewModel = HomeViewModel()
    SearchBarView(searchText: $viewModel.searchText)
    
}
