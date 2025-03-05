import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack{
                VStack{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    Text(viewModel.userName).font(.title).fontWeight(.bold)
                    Text("\(viewModel.userName.lowercased())@gmail.com").font(.caption)
                }.padding(.init(top: 50, leading:0, bottom: 20, trailing: 0))

                List {
                    Section("App Settings") {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                        
                        NavigationLink(destination: Text("Notifications Settings")) {
                            Label("Notifications", systemImage: "bell")
                        }
                        
                        NavigationLink(destination: Text("Language Settings")) {
                            Label("Language", systemImage: "globe")
                        }
                    }
                    
                    Section("Scripts") {
                        NavigationLink(destination: Text("Saved Scripts")) {
                            Label("Saved Scripts", systemImage: "doc.text")
                        }
                        
                        NavigationLink(destination: Text("Script Templates")) {
                            Label("Templates", systemImage: "doc.on.doc")
                        }
                    }
                    
                    Section("Support") {
                        NavigationLink(destination: Text("Help Center")) {
                            Label("Help Center", systemImage: "questionmark.circle")
                        }
                        
                        NavigationLink(destination: Text("Privacy Policy")) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                        }
                        
                        NavigationLink(destination: Text("Terms of Service")) {
                            Label("Terms of Service", systemImage: "doc.text")
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showingLogoutAlert = true
                        } label: {
                            Label("Log Out", systemImage: "arrow.right.square")
                        }
                    }
                }}
            //.navigationTitle("Profile")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    viewModel.isLoggedIn = false// Handle logout
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    UserProfileView(viewModel: HomeViewModel.shared)
}

