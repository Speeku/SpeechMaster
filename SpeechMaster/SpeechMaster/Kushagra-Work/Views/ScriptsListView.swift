import SwiftUI

struct ScriptsListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject private var fileUploadViewModel = FileUploadViewModel()
    @State private var showNewScriptDialog = false
    @State private var showingScriptCreation = false
    @State private var searchText = ""
    @State private var selectedFilter: ScriptFilter = .all
    @State private var sortOrder: SortOrder = .newest
    @State private var showingSortMenu = false
    @State private var isEditMode = false
    @State private var selectedScripts = Set<UUID>()
    @Environment(\.dismiss) private var dismiss
    
    enum ScriptFilter: String, CaseIterable {
        case all = "All"
        case pinned = "Pinned"
        case recent = "Recent"
    }
    
    enum SortOrder: String, CaseIterable {
        case newest = "Newest First"
        case oldest = "Oldest First"
        case alphabetical = "A to Z"
        case reverseAlphabetical = "Z to A"
    }
    
    var filteredScripts: [Script] {
        let searchResults = searchText.isEmpty ? viewModel.scripts : viewModel.scripts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        
        let filtered = switch selectedFilter {
        case .all: searchResults
        case .pinned: searchResults.filter { $0.isPinned }
        case .recent: Array(searchResults.prefix(5))
        }
        
        return filtered.sorted { first, second in
            switch sortOrder {
            case .newest:
                return first.createdAt > second.createdAt
            case .oldest:
                return first.createdAt < second.createdAt
            case .alphabetical:
                return first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
            case .reverseAlphabetical:
                return first.title.localizedCaseInsensitiveCompare(second.title) == .orderedDescending
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            VStack(spacing: 8) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ScriptFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: { 
                                        withAnimation { selectedFilter = filter }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button {
                                withAnimation { sortOrder = order }
                            } label: {
                                HStack {
                                    Text(order.rawValue)
                                    if sortOrder == order {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    .padding(.trailing)
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            if filteredScripts.isEmpty {
                emptyStateView
                    .transition(.opacity)
            } else {
                List {
                    ForEach(filteredScripts) { script in
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
                                .contextMenu {
                                    Button {
                                        viewModel.togglePin(for: script)
                                    } label: {
                                        Label(script.isPinned ? "Unpin" : "Pin to Top",
                                              systemImage: script.isPinned ? "pin.slash" : "pin")
                                    }
                                    
                                    Button {
                                        // Navigate to practice
                                        let destination = StoryboardView(script: script)
                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                           let window = windowScene.windows.first,
                                           let rootViewController = window.rootViewController {
                                            rootViewController.navigationController?.pushViewController(UIHostingController(rootView: destination), animated: true)
                                        }
                                    } label: {
                                        Label("Practice", systemImage: "mic")
                                    }
                                    
                                    Button(role: .destructive) {
                                        viewModel.deleteScript(script)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .animation(.spring(), value: filteredScripts)
                }
                .listStyle(.plain)
                .refreshable {
                    // Refresh scripts data if needed
                }
            }
        }
        .navigationTitle("My Scripts")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showNewScriptDialog = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("New Practice", isPresented: $showNewScriptDialog, titleVisibility: .visible) {
            Button("Upload Script") {
                fileUploadViewModel.showingFilePicker = true
            }
            Button("Create New Script") {
                showingScriptCreation = true
            }
        }
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
            }.navigationDestination(isPresented: $viewModel.navigateToPiyushScreen) {
                KeyNoteOptionsStoryboardView(successText: viewModel.uploadedScriptText)
                  }
        }
        NavigationLink(destination: ScriptCreationView(viewModel: viewModel), isActive: $showingScriptCreation) {
        }
        

    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .symbolEffect(.bounce, options: .repeating, value: searchText.isEmpty && selectedFilter == .all)
            
            Text("No Scripts Found")
                .font(.title2)
                .fontWeight(.bold)
            
            if searchText.isEmpty && selectedFilter == .all {
                Text("Create your first script to begin your speaking journey")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: { showNewScriptDialog = true }) {
                    Label("Create New Script", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            } else {
                Text("Try adjusting your search or filters")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search scripts...", text: $text)
                .textFieldStyle(.plain)
                .submitLabel(.search)
            if !text.isEmpty {
                Button(action: { 
                    withAnimation {
                        text = "" 
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationView {
        ScriptsListView(viewModel: HomeViewModel.shared)
    }
}
