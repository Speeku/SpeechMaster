import SwiftUI
import UIKit
struct LandingPageView: View {
    @StateObject private var viewModel = HomeViewModel.shared
    @StateObject private var videoViewModel = VideoPlayerViewModel()
    @StateObject private var fileUploadViewModel = FileUploadViewModel()
    @State private var showingActionSheet = false
    @State private var showingScriptCreation = false
    @State private var showingDiscardAlert = false
    @Environment(\.dismiss) private var dismiss // Add this line

    private func deleteScript(at offsets: IndexSet) {
        viewModel.scripts.remove(atOffsets: offsets)
   }
    func unwindSegue(_ unwindSegue: UIStoryboardSegue) {
        
    }
    private var emptyScriptsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Click on + button to start your first practice")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading,spacing: 0) {
                    VStack(alignment: .leading,spacing:20) {
                        
                        // Header
                        HStack {
                            Text("Eloquent")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                            //NavigationLink(destination: UserProfileView(viewModel: viewModel)) {
                               // Image(systemName: "person.circle.fill")
                               //     .resizable()
                                //    .frame(width: 38, height: 38)
                                //    .clipShape(Circle())
                                //    .foregroundColor(.gray)
                          //  }
                        }
                        .padding(.horizontal, 17)
                        
                        // Search Bar
                        //SearchBarView(searchText: $viewModel.searchText)
                    }.padding(.top, 22)
                        .padding(.bottom,5)
                        //.background(Color.white)
                    
                    ScrollView(showsIndicators: false){
                        VStack(alignment: .leading, spacing: 20) {
                            //Highlights
                            VStack(alignment: .leading) {
                                Text("Highlights")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 17)
                                NavigationLink(destination: ScriptCreationView(viewModel: viewModel)) {
                                Image("Highlights").resizable()
                                        .frame(height:120)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .padding(.horizontal)
                                        .padding(.top,-8)
                                    

                                }
                                
                            }.padding(.top,15)
                            // Top Speeches Section
                            VStack(alignment: .leading) {
                                Text("Top Speakers")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 17)
                                    .padding(.bottom,-1)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(viewModel.topSpeeches) { speech in
                                            NavigationLink(destination: SpeechDetailView(speech: speech, viewModel: videoViewModel)) {
                                                TopSpeechCard(speech: speech)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                
                                }
                            }

                            // Progress Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Progress")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 17)

                                ProgressCardView(
                                    viewModel: viewModel,
                                    title: "Overall Improvement",
                                    progress: viewModel.calculateOverallImprovement(for: viewModel.scripts.first?.id),
                                    fgColor: .black,
                                    bgColor: Color.green.opacity(0.1),
                                    circleColor: .green,
                                    lastCreatedScriptName: viewModel.scripts.first?.title ?? "No recent scripts"
                                )
                                .padding(.horizontal, 17)
                                .padding(.top,-10)
                            }
                            .padding(.vertical, 8)

                            // My Scripts Section
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Recent Scripts")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                    if !viewModel.isScriptsEmpty() {
                                        NavigationLink(destination: ScriptsListView(viewModel: viewModel)) {
                                            Text("See all")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.horizontal, 17)

                                if viewModel.isScriptsEmpty() {
                                    emptyScriptsView.padding()
                                    Spacer()
                                } else {
                                    ScriptsList(scripts: viewModel.scripts, viewModel: viewModel)
                                        .padding(.horizontal)
                                    
                                }
                            }
                        }
                    }
                }
                .background(Color.appBackground)

                // New Practice Button
                Button(action: { showingActionSheet = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Practice")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
                .padding()
                .confirmationDialog("New Practice", isPresented: $showingActionSheet, titleVisibility: .visible) {
                    Button("Upload Script") {
                        fileUploadViewModel.showingFilePicker = true
                    }
                    Button("Create New Script") {
                        showingScriptCreation = true
                    }
                }
            }
            NavigationLink(destination: ScriptCreationView(viewModel: viewModel), isActive: $showingScriptCreation) {

            }
            NavigationLink(destination: KeyNoteOptionsStoryboardView(), isActive: $viewModel.navigateToPiyushScreen) {
                
            }
            
          
//            .sheet(isPresented: $showingScriptCreation) {
//                ScriptCreationView(viewModel: viewModel)
//            }
            .fileImporter(
                isPresented: $fileUploadViewModel.showingFilePicker,
                allowedContentTypes: fileUploadViewModel.getSupportedTypes(),
                allowsMultipleSelection: false
            ) { result in
                fileUploadViewModel.handleFileSelection(result)
            }
            .alert(fileUploadViewModel.alertMessage, isPresented: $fileUploadViewModel.showingAlert) {
                Button("OK") {
                    if viewModel.navigateToPiyushScreen {
                        viewModel.navigateToPiyushScreen = false
                        viewModel.navigateToPiyushScreen = true
                        viewModel.uploadedScriptText = fileUploadViewModel.uploadedScriptText
                        let newScript = Script(id: UUID(), title:"Script \(viewModel.scripts.count + 1)", scriptText: fileUploadViewModel.uploadedScriptText, createdAt: Date(), isPinned: false)
                    }
                }
                
            }
            .toolbar(.hidden)
        }
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) {
                dismiss() // Fixed usage of dismiss here
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    LandingPageView()
}
