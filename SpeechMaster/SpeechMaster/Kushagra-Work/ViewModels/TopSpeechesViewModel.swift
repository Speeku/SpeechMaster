import Foundation
import Combine

final class TopSpeechesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var speeches: [TopSpeech] = []
    @Published var selectedCategory: SpeechCategory?
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var selectedSpeech: TopSpeech?
    @Published var showingSpeechDetail = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var filteredSpeeches: [TopSpeech] {
        var filtered = speeches
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    var featuredSpeeches: [TopSpeech] {
        speeches.filter { $0.isFeatured }
    }
    
    var categories: [SpeechCategory] {
        SpeechCategory.allCases
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadSpeeches()
        setupSearchDebounce()
    }
    
    // MARK: - Private Methods
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func loadSpeeches() {
        isLoading = true
        
        // Simulated data loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.speeches = [
                TopSpeech(
                    id: UUID(),
                    title: "Steve Jobs",
                    description: "Unveiling the iPhone (2007)",
                    imageName: "steve_jobs",
                    category: .technology,
                    duration: 2160, // 36 minutes
                    views: 15_000_000,
                    rating: 4.9,
                    tags: ["innovation", "technology", "apple", "iphone"],
                    isFeatured: true
                ),
                TopSpeech(
                    id: UUID(),
                    title: "Barack Obama",
                    description: "Speech on Education (2004)",
                    imageName: "barack_obama",
                    category: .education,
                    duration: 1800, // 30 minutes
                    views: 8_500_000,
                    rating: 4.8,
                    tags: ["education", "politics", "inspiration"],
                    isFeatured: true
                ),
                // Add more speeches here...
            ]
            
            self?.isLoading = false
        }
    }
    
    // MARK: - Public Methods
    func selectCategory(_ category: SpeechCategory?) {
        withAnimation {
            selectedCategory = category
        }
    }
    
    func selectSpeech(_ speech: TopSpeech) {
        selectedSpeech = speech
        showingSpeechDetail = true
    }
    
    func refreshSpeeches() {
        loadSpeeches()
    }
    
    func toggleFavorite(for speechId: UUID) {
        // Implement favorite functionality
    }
    
    func share(speech: TopSpeech) {
        // Implement share functionality
    }
} 
