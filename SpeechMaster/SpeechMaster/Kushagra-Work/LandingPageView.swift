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
                            Text("Hi \(viewModel.userName)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                            NavigationLink(destination: UserProfileView(viewModel: viewModel)) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 38, height: 38)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 17)
                        
                        // Search Bar
                        SearchBarView(searchText: $viewModel.searchText)
                    }.padding(.bottom,20)
                        .padding(.top, 22)
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
                                        .frame(width: .infinity, height:135)
                                    //.clipShape(.rect(cornerRadius: 10))

                                }
                                
                            }.padding(.top,15)
                            // Top Speeches Section
                            VStack(alignment: .leading) {
                                Text("Top Speakers")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 17)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(viewModel.topSpeeches) { speech in
                                            NavigationLink(destination: SpeechDetailView(speech: speech, viewModel: videoViewModel)) {
                                                TopSpeechCard(speech: speech)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 22)
                                }
                            }

                            // Progress Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Progress")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)

//                                ScrollView(.horizontal, showsIndicators: false) {
//                                        ProgressCardView(
//                                            title: "Audience Engagement",
//                                            progress: 80,
//                                            fgColor: .white,
//                                            bgColor: Color(hex: "1A4D2E"),
//                                            circleColor: .orange,
//                                            lastCreatedScriptName: viewModel.scripts.first?.title
//                                        )
//                                        .frame(width: 300)
//                                        
                                        ProgressCardView(
                                            viewModel: viewModel, title: "Overall Improvement",
                                            progress: viewModel.overallImprovement,
                                            fgColor: .black,
                                            bgColor: .green.opacity(0.1),
                                            circleColor: .green,
                                            lastCreatedScriptName: viewModel.scripts.first?.title
                                        )
                                        .frame(width: .infinity).padding(.horizontal)
                                        
//                                        ProgressCardView(
//                                            title: "Practice Streak",
//                                            progress: 60,
//                                            fgColor: .white,
//                                            bgColor: Color(hex: "2C3333"),
//                                            circleColor: .blue,
//                                            lastCreatedScriptName: viewModel.scripts.first?.title
//                                        )
//                                        .frame(width: 300)
//                                }
//                                .scrollClipDisabled()
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
                                    Spacer()
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
                    if fileUploadViewModel.navigateToPiyushScreen {
                        fileUploadViewModel.navigateToPiyushScreen = false
                        viewModel.navigateToPiyushScreen = true
                        viewModel.uploadedScriptText = fileUploadViewModel.uploadedScriptText
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToPiyushScreen) {
                KeyNoteOptionsStoryboardView(successText: viewModel.uploadedScriptText)
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
