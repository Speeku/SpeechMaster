import Foundation
import GoogleGenerativeAI

private enum StorageKeys {
    static let scripts = "saved_scripts"
    static let sessions = "practice_sessions"
    static let qnaSessions = "qna_sessions"
    static let qnaQuestions = "qna_questions"
    static let performanceReports = "performance_reports"
    static let userName = "user_name"
//    static let overallImprovement = "overall_improvement"
}

class HomeViewModel: ObservableObject {
    // MARK: - Singleton
    static let shared = HomeViewModel()
    
    // MARK: - Published Properties
    @Published var userName: String = "Piyush"
    @Published var scripts: [Script] = []
    @Published var isLoggedIn: Bool = true
    @Published var searchText: String = ""
    @Published var overallImprovement: Double = 10
    @Published var navigateToPiyushScreen = false
    @Published var uploadedScriptText = ""
    @Published var currentScriptID: UUID = UUID()
    @Published var sessionsArray: [PracticeSession] = []
    @Published var qnaArray: [QnASession] = []
    @Published var userPerformanceReports : [PerformanceReport] = []
    @Published var qnaQuestions: [QnAQuestion] = []
    // MARK: - API Configuration
    private let geminiAPIEndpoint = "YOUR_GEMINI_API_ENDPOINT"
    private var geminiAPIKey: String {
        // In production, this should be stored securely
        // For now, we'll use a placeholder
        "AIzaSyBbpl3vZYTRTwcfra97T-NdsR2TIfCICOY"
    }
    
    // MARK: - Initialization
    private init() {
        // Private initializer to ensure singleton pattern
        loadData()
    }
    
    // MARK: - AI Content Generation
//    private let model = GenerativeModel(name: "gemini-pro",
//                                        apiKey: "AIzaSyBbpl3vZYTRTwcfra97T-NdsR2TIfCICOY")
    let model = GenerativeModel(name: "models/gemini-1.5-flash", apiKey: APIKey.default)
    func generateScript(prompt: String) async throws -> String {
        do {
            let promptText = """
            You are a professional speech writer. Create a well-structured presentation script that is:
            1. Clear and engaging
            2. Organized with proper sections
            3. Includes natural transitions
            4. Has a strong opening and conclusion
            5. Uses appropriate pacing for verbal delivery
            
            Create a presentation script about: \(prompt)
            
            Format the output as a proper speech script with clear sections.
            """
            
            // Create a chat session
            let chat = model.startChat()
            
            // Generate content with safety settings
            let response = try await chat.sendMessage(promptText)
            
            if let responseText = response.text {
                return responseText
            } else {
                throw NSError(domain: "", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to generate response"])
            }
        } catch {
            print("Gemini API Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Script Management
    func addScript(_ script: Script) {
        DispatchQueue.main.async {
            self.scripts.append(script)
            self.sortScripts()
            self.saveData()
        }
    }
    
    func deleteScript(_ script: Script) {
        DispatchQueue.main.async {
            self.scripts.removeAll { $0.id == script.id }
            self.sortScripts()
            self.saveData()
        }
    }
    
    func deleteScript(at indexSet: IndexSet) {
        DispatchQueue.main.async {
            self.scripts.remove(atOffsets: indexSet)
            self.sortScripts()
            self.saveData()
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
    
    func getScriptText(for scriptId: UUID) -> String {
        if let script = scripts.first(where: { $0.id == scriptId }) {
            print("📝 Found script with ID: \(scriptId)")
            print("📊 Script word count: \(script.scriptText.split(separator: " ").count)")
            return script.scriptText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        print("⚠️ No script found for ID: \(scriptId)")
        return ""
    }
    
    // MARK: -  QNA Session Management
    
    func addQnASessions(_ qna: QnASession) {
        DispatchQueue.main.async {
            self.qnaArray.append(qna)
            self.saveData()
        }
    }
    
    func addSession(_ session: PracticeSession) {
        DispatchQueue.main.async {
            self.sessionsArray.append(session)
            self.saveData()
        }
    }
    
    func getAllSessions() -> [PracticeSession] {
        return sessionsArray
    }
    
    func getSessions(for scriptId: UUID) -> [PracticeSession] {
        return sessionsArray.filter { $0.scriptId == scriptId }
            .sorted { $0.createdAt > $1.createdAt } // Sort by creation date, newest first
    }
    //    func getQnASessions(for scriptId: UUID) -> [QnASession] {
    //        return qnaArray.filter { $0.scriptId == scriptId }
    //    }
    //
    // MARK: - Qna methods
    
    func addQnAQuestions(_ questions: [QnAQuestion]) {
        DispatchQueue.main.async {
            self.qnaQuestions.append(contentsOf: questions)
            self.saveData()
            print("Added \(questions.count) questions to storage")
        }
    }
    
    func getQuestions(for sessionId: UUID) -> [QnAQuestion] {
        return qnaQuestions.filter { $0.qna_session_Id == sessionId }
    }
    
    func getQnASessions(for scriptId: UUID) -> [QnASession] {
        return qnaArray.filter { $0.scriptId == scriptId }
        // MARK: - Performance Report Management
    }
        func addPerformanceReport(_ report: PerformanceReport) {
            DispatchQueue.main.async {
                if let existingIndex = self.userPerformanceReports.firstIndex(where: { $0.sessionID == report.sessionID }) {
                    self.userPerformanceReports[existingIndex] = report
                } else {
                    self.userPerformanceReports.append(report)
                }
                self.saveData()
                self.objectWillChange.send()
            }
        }
        
        func getPerformanceReport(for sessionID: UUID) -> PerformanceReport? {
            return userPerformanceReports.first { $0.sessionID == sessionID }
        }
        
        func getAllPerformanceReports() -> [PerformanceReport] {
            return userPerformanceReports.sorted { $0.sessionID > $1.sessionID }
        }
        
        // MARK: - Data Persistence
        private func saveData() {
            let encoder = JSONEncoder()
            if let scriptsData = try? encoder.encode(scripts) {
                UserDefaults.standard.set(scriptsData, forKey: StorageKeys.scripts)
            }
            if let sessionsData = try? encoder.encode(sessionsArray) {
                UserDefaults.standard.set(sessionsData, forKey: StorageKeys.sessions)
            }
            if let qnaSessionsData = try? encoder.encode(qnaArray) {
                UserDefaults.standard.set(qnaSessionsData, forKey: StorageKeys.qnaSessions)
            }
            if let qnaQuestionsData = try? encoder.encode(qnaQuestions) {
                UserDefaults.standard.set(qnaQuestionsData, forKey: StorageKeys.qnaQuestions)
            }
            if let reportsData = try? encoder.encode(userPerformanceReports) {
                UserDefaults.standard.set(reportsData, forKey: StorageKeys.performanceReports)
            }
            
            UserDefaults.standard.set(userName, forKey: StorageKeys.userName)
           // UserDefaults.standard.set(overallImprovement, forKey: StorageKeys.overallImprovement)
        }
        
        private func loadData() {
            let decoder = JSONDecoder()
            
            if let scriptsData = UserDefaults.standard.data(forKey: StorageKeys.scripts),
               let decodedScripts = try? decoder.decode([Script].self, from: scriptsData) {
                scripts = decodedScripts
            }
            
            if let sessionsData = UserDefaults.standard.data(forKey: StorageKeys.sessions),
               let decodedSessions = try? decoder.decode([PracticeSession].self, from: sessionsData) {
                sessionsArray = decodedSessions
            }
            
            if let qnaSessionsData = UserDefaults.standard.data(forKey: StorageKeys.qnaSessions),
               let decodedQnASessions = try? decoder.decode([QnASession].self, from: qnaSessionsData) {
                qnaArray = decodedQnASessions
            }
            
            if let qnaQuestionsData = UserDefaults.standard.data(forKey: StorageKeys.qnaQuestions),
               let decodedQuestions = try? decoder.decode([QnAQuestion].self, from: qnaQuestionsData) {
                qnaQuestions = decodedQuestions
            }
            
            if let reportsData = UserDefaults.standard.data(forKey: StorageKeys.performanceReports),
               let decodedReports = try? decoder.decode([PerformanceReport].self, from: reportsData) {
                userPerformanceReports = decodedReports
            }
            
            userName = UserDefaults.standard.string(forKey: StorageKeys.userName) ?? "User"
           // overallImprovement = UserDefaults.standard.double(forKey: StorageKeys.overallImprovement)
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
        
        // MARK: - Error Handling
        enum NetworkError: Error {
            case invalidURL
            case invalidResponse(String)
            case invalidData
            
            var localizedDescription: String {
                switch self {
                case .invalidURL:
                    return "Invalid URL. Please check the API endpoint."
                case .invalidResponse(let message):
                    return message
                case .invalidData:
                    return "Invalid data received from the server."
                }
            }
        }
    }

