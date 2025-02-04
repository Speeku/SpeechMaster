import SwiftUI
import UIKit
struct LandingPageView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var videoViewModel = VideoPlayerViewModel()
    @StateObject private var fileUploadViewModel = FileUploadViewModel()
    @State private var showingActionSheet = false
    @State private var showingScriptCreation = false
    @State private var showingDiscardAlert = false
    @Environment(\.dismiss) private var dismiss // Add this line

    private func deleteScript(at offsets: IndexSet) {
        viewModel.scripts.remove(atOffsets: offsets)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 20) {
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
                    .padding(.top, 8)

                    // Search Bar
                    SearchBarView(searchText: $viewModel.searchText)

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
                                        .frame(width: 358, height:120).padding(.init(top: 0, leading:22, bottom: 0, trailing:5))
                                    .clipShape(.rect(cornerRadius: 10))

                                }
                                
                            }
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
                            VStack(alignment: .leading) {
                                Text("Progress")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)

                                HStack(spacing: 10) {
                                    ProgressCardView(title: "Audience Engagement", progress: viewModel.audienceEngagement, fgColor: .white, bgColor: .progressCardColorAudienceEngagement, circleColor: .orange, lastCreatedScriptName: viewModel.scripts.first?.title ?? "")
                                    ProgressCardView(title: "Overall Improvement", progress: viewModel.overallImprovement, fgColor: .black, bgColor: .progressCardColorOverallImprovement, circleColor: .green, lastCreatedScriptName: viewModel.scripts.first?.title ?? "")
                                }
                                .padding(.horizontal)
                            }

                            // My Scripts Section
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("My Scripts")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                    if !viewModel.isScriptsEmpty() {
                                        NavigationLink(destination: Text("All Scripts")) {
                                            Text("See all")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.horizontal, 17)

                                if viewModel.isScriptsEmpty() {
                                    Text("Click on + button to start your first practice")
                                        .foregroundColor(.gray)
                                        .padding(.init(top: 40, leading: 35, bottom: 0, trailing: 35))
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
                KeyNoteOptionsStoryboardView()
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
