import Foundation

class HomeViewModel: ObservableObject {
    // MARK: - Singleton
    static let shared = HomeViewModel()
    
    // MARK: - Published Properties
    @Published var userName: String = "Piyush"
    @Published var scripts: [Script] = []
    @Published var isLoggedIn: Bool = true
    @Published var searchText: String = ""
    //@Published var audienceEngagement: Double = 80
    @Published var overallImprovement: Double = 0
    @Published var navigateToPiyushScreen = false
    @Published var uploadedScriptText = ""
    @Published var currentScriptID: UUID = UUID()
    // MARK: - Script Management
    
    private init() {
        // Private initializer to ensure singleton pattern
        // Load any saved data here if needed
    }
    
    func addScript(_ script: Script) {
        DispatchQueue.main.async {
            self.scripts.append(script)
            self.sortScripts()
        }
    }
    
    func deleteScript(_ script: Script) {
        DispatchQueue.main.async {
            self.scripts.removeAll { $0.id == script.id }
            self.sortScripts()
        }
    }
    
    func deleteScript(at indexSet: IndexSet) {
        DispatchQueue.main.async {
            self.scripts.remove(atOffsets: indexSet)
            self.sortScripts()
        }
    }
    
    func pinToTop(_ script: Script) {
        if let index = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[index].isPinned = true
            sortScripts()
        }
    }
    
    func unpinScript(_ script: Script) {
        if let index = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[index].isPinned = false
            sortScripts()
        }
    }
    
    func togglePin(for script: Script) {
        DispatchQueue.main.async {
            if let index = self.scripts.firstIndex(where: { $0.id == script.id }) {
                self.scripts[index].isPinned.toggle()
                self.sortScripts()
            }
        }
    }
    
    private func sortScripts() {
        scripts.sort { (script1:Script, script2:Script) in
            if script1.isPinned && !script2.isPinned {
                return true
            }
            if !script1.isPinned && script2.isPinned {
                return false
            }
            return script1.createdAt > script2.createdAt
        }
        objectWillChange.send()
    }
    
    func isScriptsEmpty() -> Bool {
        return scripts.isEmpty || !isLoggedIn
    }
    // MARK: - Top Speeches
    @Published var selectedCategory: SpeechCategory?
    @Published var selectedTags: Set<String> = []
    
    let topSpeeches: [TopSpeech] = [
        TopSpeech(
            title: "Steve Jobs",
            description: "Unveiling the iPhone (2007)",
            imageName: "steve_jobs",
            category: .technology,
            year: 2007,
            duration: 2220, // 37 minutes
            tags: ["innovation", "product launch", "technology", "apple"],
            isFeatured: true
        ),
        TopSpeech(
            title: "Barack Obama",
            description: "Speech on Education (2004)",
            imageName: "barack_obama",
            category: .education,
            year: 2004,
            duration: 1500, // 25 minutes
            tags: ["education", "policy", "reform", "leadership"],
            isFeatured: true
        ),
        TopSpeech(
            title: "Roger Federer",
            description: "Cambridge Union Speech (2019)",
            imageName: "roger_federer",
            category: .sports,
            year: 2019,
            duration: 1800, // 30 minutes
            tags: ["sports", "tennis", "success", "perseverance"],
            isFeatured: false
        ),
        TopSpeech(
            title: "Martin Luther King Jr.",
            description: "I Have a Dream (1963)",
            imageName: "martin_luther_king",
            category: .politics,
            year: 1963,
            duration: 1020, // 17 minutes
            tags: ["civil rights", "equality", "justice", "history"],
            isFeatured: true
        ),
        TopSpeech(
            title: "Simon Sinek",
            description: "How Great Leaders Inspire Action (2009)",
            imageName: "simon_sinek",
            category: .leadership,
            year: 2009,
            duration: 1080, // 18 minutes
            tags: ["leadership", "motivation", "business", "inspiration"],
            isFeatured: true
        ),
        TopSpeech(
            title: "Brene Brown",
            description: "The Power of Vulnerability (2010)",
            imageName: "brene_brown",
            category: .motivation,
            year: 2010,
            duration: 1200, // 20 minutes
            tags: ["vulnerability", "personal growth", "psychology"],
            isFeatured: false
        ),
        TopSpeech(
            title: "Elon Musk",
            description: "Tesla and SpaceX Vision (2016)",
            imageName: "elon_musk",
            category: .technology,
            year: 2016,
            duration: 2400, // 40 minutes
            tags: ["space", "electric vehicles", "innovation", "future"],
            isFeatured: true
        ),
        TopSpeech(
            title: "Malala Yousafzai",
            description: "UN Youth Assembly Speech (2013)",
            imageName: "malala_yousafzai",
            category: .education,
            year: 2013,
            duration: 900, // 15 minutes
            tags: ["education", "human rights", "youth", "activism"],
            isFeatured: true
        ),
        TopSpeech(
            title: "J.K. Rowling",
            description: "Harvard Commencement Speech (2008)",
            imageName: "jk_rowling",
            category: .literature,
            year: 2008,
            duration: 1500, // 25 minutes
            tags: ["creativity", "perseverance", "success", "writing"],
            isFeatured: false
        ),
        TopSpeech(
            title: "Winston Churchill",
            description: "We Shall Fight on the Beaches (1940)",
            imageName: "winston_churchill",
            category: .politics,
            year: 1940,
            duration: 720, // 12 minutes
            tags: ["war", "leadership", "history", "inspiration"],
            isFeatured: true
        )
    ]
    
    // MARK: - Speech Filtering Methods
    
    /// Returns speeches filtered by category and tags
    var filteredSpeeches: [TopSpeech] {
        var filtered = topSpeeches
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !selectedTags.isEmpty {
            filtered = filtered.filter { speech in
                !selectedTags.isDisjoint(with: speech.tags)
            }
        }
        
        return filtered
    }
    
    /// Returns only featured speeches
    var featuredSpeeches: [TopSpeech] {
        topSpeeches.filter { $0.isFeatured }
    }
    
    /// Returns all unique tags from speeches
    var allTags: Set<String> {
        Set(topSpeeches.flatMap { $0.tags })
    }
    
    /// Returns speeches grouped by category
    var speechesByCategory: [SpeechCategory: [TopSpeech]] {
        Dictionary(grouping: topSpeeches) { $0.category }
    }
    
    /// Formats duration into readable string
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}
