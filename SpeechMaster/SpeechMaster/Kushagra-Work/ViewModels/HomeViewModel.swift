import Foundation
import GoogleGenerativeAI
import Combine
import SwiftUI

private enum StorageKeys {
    static let sessions = "practice_sessions"
    static let qnaSessions = "qna_sessions"
    static let qnaQuestions = "qna_questions"
    static let performanceReports = "performance_reports"
    static let userName = "user_name"
    static let overallImprovement = "overall_improvement"
}

class HomeViewModel: ObservableObject {
    // MARK: - Singleton
    static let shared = HomeViewModel()
    
    // MARK: - Published Properties
    @Published var userName: String = ""
    @Published var scripts: [Script] = []
    @Published var isLoggedIn: Bool = true
    @Published var searchText: String = ""
    @Published var overallImprovement: Double = 0
    @Published var navigateToPiyushScreen = false
    @Published var uploadedScriptText = ""
    @Published var currentScriptID: UUID = UUID()
    @Published var sessionsArray: [PracticeSession] = []
    @Published var qnaArray: [QnASession] = []
    @Published var userPerformanceReports : [PerformanceReport] = []
    @Published var qnaQuestions: [QnAQuestion] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Services
    private let supabaseManager = SupabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
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
        
        // Load scripts from Supabase when user is logged in
        if supabaseManager.currentUser != nil {
            Task {
                await loadScriptsFromSupabase()
            }
        }
        
        // Set up notification observers
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Listen for refresh data notification
        NotificationCenter.default.publisher(for: NSNotification.Name("RefreshSupabaseData"))
            .sink { [weak self] _ in
                print("Received notification to refresh Supabase data")
                guard let self = self else { return }
                
                Task {
                    await self.loadScriptsFromSupabase()
                }
            }
            .store(in: &cancellables)
        
        // Listen for view appearance in SwiftUI
        NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)
            .sink { [weak self] _ in
                print("App will enter foreground - refreshing scripts")
                guard let self = self else { return }
                
                if self.isLoggedIn && supabaseManager.currentUser != nil {
                    Task {
                        await self.loadScriptsFromSupabase()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Landing Page Appearance
    
    /// Call this method when landing page appears
    func onLandingPageAppear() {
        if isLoggedIn && supabaseManager.currentUser != nil {
            Task {
                await loadScriptsFromSupabase()
            }
        }
    }
    
    // MARK: - AI Content Generation
    let model = GenerativeModel(name: "models/gemini-1.5-pro-001", apiKey: APIKey.default)
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
    
    // MARK: - Supabase Script Management
    
    /// Load scripts from Supabase
    @MainActor
    func loadScriptsFromSupabase() async {
        guard supabaseManager.currentUser != nil else {
            print("Cannot load scripts: No user logged in")
            return
        }
        
        isLoading = true
        
        do {
            let fetchedScripts = try await supabaseManager.fetchScripts()
            self.scripts = fetchedScripts
            self.sortScripts()
            isLoading = false
            print("Successfully loaded \(fetchedScripts.count) scripts from Supabase")
        } catch {
            print("Error loading scripts from Supabase: \(error)")
            isLoading = false
        }
    }
    
    /// Add a new script to Supabase
    func addScript(_ script: Script) {
        Task {
            do {
                let newScript = try await supabaseManager.createScript(
                    title: script.title,
                    scriptText: script.scriptText,
                    isPinned: script.isPinned
                )
                
                await MainActor.run {
                    self.scripts.append(newScript)
                    self.sortScripts()
                }
                print("Successfully added script to Supabase: \(newScript.id)")
            } catch {
                print("Error adding script to Supabase: \(error)")
            }
        }
    }
    
    /// Delete a script from Supabase
    func deleteScript(_ script: Script) {
        Task {
            do {
                try await supabaseManager.deleteScript(id: script.id)
                
                await MainActor.run {
                    self.scripts.removeAll { $0.id == script.id }
                    self.sortScripts()
                }
                print("Successfully deleted script from Supabase: \(script.id)")
            } catch {
                print("Error deleting script from Supabase: \(error)")
            }
        }
    }
    
    /// Delete a script at specified index
    func deleteScript(at indexSet: IndexSet) {
        for index in indexSet {
            let scriptToDelete = scripts[index]
            deleteScript(scriptToDelete)
        }
    }
    
    /// Toggle pin status for a script
    func togglePin(for script: Script) {
        Task {
            do {
                let toggledPinStatus = !script.isPinned
                let updatedScript = try await supabaseManager.updateScript(
                    id: script.id,
                    isPinned: toggledPinStatus
                )
                
                await MainActor.run {
                    if let index = self.scripts.firstIndex(where: { $0.id == script.id }) {
                        self.scripts[index] = updatedScript
                        self.sortScripts()
                    }
                }
                print("Successfully toggled pin status for script: \(script.id)")
            } catch {
                print("Error toggling pin status: \(error)")
            }
        }
    }
    
    /// Pin a script to the top
    func pinToTop(_ script: Script) {
        Task {
            do {
                let updatedScript = try await supabaseManager.updateScript(
                    id: script.id,
                    isPinned: true
                )
                
                await MainActor.run {
                    if let index = self.scripts.firstIndex(where: { $0.id == script.id }) {
                        self.scripts[index] = updatedScript
                        self.sortScripts()
                    }
                }
                print("Successfully pinned script: \(script.id)")
            } catch {
                print("Error pinning script: \(error)")
            }
        }
    }
    
    /// Unpin a script
    func unpinScript(_ script: Script) {
        Task {
            do {
                let updatedScript = try await supabaseManager.updateScript(
                    id: script.id,
                    isPinned: false
                )
                
                await MainActor.run {
                    if let index = self.scripts.firstIndex(where: { $0.id == script.id }) {
                        self.scripts[index] = updatedScript
                        self.sortScripts()
                    }
                }
                print("Successfully unpinned script: \(script.id)")
            } catch {
                print("Error unpinning script: \(error)")
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
    
    func getScriptTitle(for scriptId: UUID) -> String {
        if let script = scripts.first(where: { $0.id == scriptId }) {
            return script.title
        }
        return "Untitled Script"
    }
    
    func setScriptText(for scriptId: UUID, text: String) {
        Task {
            do {
                let updatedScript = try await supabaseManager.updateScript(
                    id: scriptId,
                    scriptText: text.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                await MainActor.run {
                    if let index = self.scripts.firstIndex(where: { $0.id == scriptId }) {
                        self.scripts[index] = updatedScript
                    }
                }
                print("📝 Updated script with ID: \(scriptId)")
                print("📊 New script word count: \(text.split(separator: " ").count)")
            } catch {
                print("⚠️ Error updating script text: \(error)")
            }
        }
    }
    
    // MARK: -  QNA Session Management
    
    func addQnASessions(_ qna: QnASession) {
        DispatchQueue.main.async {
            self.qnaArray.append(qna)
            self.saveData()
        }
    }
    
    func addSession(_ session: PracticeSession) {
        Task {
            do {
                let newSession = try await supabaseManager.createPracticeSession(
                    scriptId: session.scriptId,
                    title: session.title
                )
                
                await MainActor.run {
                    self.sessionsArray.append(newSession)
                    self.objectWillChange.send()
                }
                print("Successfully added practice session to Supabase: \(newSession.id)")
            } catch {
                print("Error adding practice session to Supabase: \(error)")
                // Fallback to local storage if Supabase fails
                await MainActor.run {
                    self.sessionsArray.append(session)
                    self.saveData()
                }
            }
        }
    }
    
    func getAllSessions() -> [PracticeSession] {
        return sessionsArray
    }
    
    @MainActor
    func loadPracticeSessionsFromSupabase(for scriptId: UUID) async {
        guard supabaseManager.currentUser != nil else {
            print("Cannot load practice sessions: No user logged in")
            return
        }
        
        do {
            let fetchedSessions = try await supabaseManager.fetchPracticeSessions(for: scriptId)
            self.sessionsArray = fetchedSessions
            print("Successfully loaded \(fetchedSessions.count) practice sessions from Supabase")
        } catch {
            print("Error loading practice sessions from Supabase: \(error)")
        }
    }
    
    func getSessions(for scriptId: UUID) -> [PracticeSession] {
        // Load sessions from Supabase if user is logged in
        if isLoggedIn && supabaseManager.currentUser != nil {
            Task {
                await loadPracticeSessionsFromSupabase(for: scriptId)
            }
        }
        
        return sessionsArray.filter { $0.scriptId == scriptId }
            .sorted { $0.createdAt > $1.createdAt } // Sort by creation date, newest first
    }
    
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
    }
    
    // MARK: - Performance Report Management
    func addPerformanceReport(_ report: PerformanceReport) {
        Task {
            do {
                let reportID = try await supabaseManager.createPerformanceReport(report: report)
                print("Successfully added performance report to Supabase: \(reportID)")
                
                // Update local cache
                await MainActor.run {
                    if let existingIndex = self.userPerformanceReports.firstIndex(where: { $0.sessionID == report.sessionID }) {
                        self.userPerformanceReports[existingIndex] = report
                    } else {
                        self.userPerformanceReports.append(report)
                    }
                    self.objectWillChange.send()
                }
            } catch {
                print("Error adding performance report to Supabase: \(error)")
                // Fallback to local storage if Supabase fails
                await MainActor.run {
                    if let existingIndex = self.userPerformanceReports.firstIndex(where: { $0.sessionID == report.sessionID }) {
                        self.userPerformanceReports[existingIndex] = report
                    } else {
                        self.userPerformanceReports.append(report)
                    }
                    self.saveData()
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func getPerformanceReport(for sessionID: UUID) -> PerformanceReport? {
        // Try to fetch from Supabase if user is logged in
        if isLoggedIn && supabaseManager.currentUser != nil {
            Task {
                do {
                    if let report = try await supabaseManager.fetchPerformanceReport(for: sessionID) {
                        await MainActor.run {
                            // Update local cache
                            if let existingIndex = self.userPerformanceReports.firstIndex(where: { $0.sessionID == sessionID }) {
                                self.userPerformanceReports[existingIndex] = report
                            } else {
                                self.userPerformanceReports.append(report)
                            }
                            self.objectWillChange.send()
                        }
                    }
                } catch {
                    print("Error fetching performance report from Supabase: \(error)")
                }
            }
        }
        
        // Return from local cache
        return userPerformanceReports.first { $0.sessionID == sessionID }
    }
    
    @MainActor
    func loadPerformanceReportsFromSupabase() async {
        guard supabaseManager.currentUser != nil else {
            print("Cannot load performance reports: No user logged in")
            return
        }
        
        do {
            let fetchedReports = try await supabaseManager.fetchAllPerformanceReports()
            self.userPerformanceReports = fetchedReports
            print("Successfully loaded \(fetchedReports.count) performance reports from Supabase")
        } catch {
            print("Error loading performance reports from Supabase: \(error)")
        }
    }
    
    func getAllPerformanceReports() -> [PerformanceReport] {
        // Load reports from Supabase if user is logged in
        if isLoggedIn && supabaseManager.currentUser != nil {
            Task {
                await loadPerformanceReportsFromSupabase()
            }
        }
        
        return userPerformanceReports.sorted { $0.sessionID > $1.sessionID }
    }
        
    // MARK: - Data Persistence
    private func saveData() {
        let encoder = JSONEncoder()
        // Scripts, Practice Sessions, and Performance Reports are now stored in Supabase
        
        // Only QnA sessions and questions are still stored locally
        if let qnaSessionsData = try? encoder.encode(qnaArray) {
            UserDefaults.standard.set(qnaSessionsData, forKey: StorageKeys.qnaSessions)
        }
        if let qnaQuestionsData = try? encoder.encode(qnaQuestions) {
            UserDefaults.standard.set(qnaQuestionsData, forKey: StorageKeys.qnaQuestions)
        }
        
        UserDefaults.standard.set(userName, forKey: StorageKeys.userName)
        UserDefaults.standard.set(overallImprovement, forKey: StorageKeys.overallImprovement)
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        
        // Scripts, Practice Sessions, and Performance Reports are now loaded from Supabase
        // We'll load them when needed using the respective methods
        
        // Only load QnA sessions and questions from local storage
        if let qnaSessionsData = UserDefaults.standard.data(forKey: StorageKeys.qnaSessions),
           let decodedQnASessions = try? decoder.decode([QnASession].self, from: qnaSessionsData) {
            qnaArray = decodedQnASessions
        }
        
        if let qnaQuestionsData = UserDefaults.standard.data(forKey: StorageKeys.qnaQuestions),
           let decodedQuestions = try? decoder.decode([QnAQuestion].self, from: qnaQuestionsData) {
            qnaQuestions = decodedQuestions
        }
        
        userName = UserDefaults.standard.string(forKey: StorageKeys.userName) ?? "User"
        overallImprovement = UserDefaults.standard.double(forKey: StorageKeys.overallImprovement)
        
        // If user is logged in, load data from Supabase
        if supabaseManager.currentUser != nil {
            Task {
                await loadScriptsFromSupabase()
                // We'll load practice sessions and performance reports when needed
            }
        }
    }
    
    // MARK: - User Authentication
    func userDidLogIn() {
        Task {
            await loadScriptsFromSupabase()
            // We'll load practice sessions and performance reports when needed
            // Clear any local-only data to ensure we're using fresh data from Supabase
            await MainActor.run {
                self.sessionsArray = []
                self.userPerformanceReports = []
            }
        }
    }
    
    func userDidLogOut() {
        DispatchQueue.main.async {
            self.scripts = []
            self.sessionsArray = []
            self.userPerformanceReports = []
        }
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
        
        func calculateOverallImprovement(for scriptId: UUID? = nil) -> Double {
            // If no scriptId provided, use the most recent script's ID
            let targetScriptId = scriptId ?? scripts.first?.id
            
            guard let scriptId = targetScriptId else { 
                DispatchQueue.main.async {
                    self.overallImprovement = 0
                }
                return 0 
            }
            
            // Filter reports for the specific script
            let scriptSessions = sessionsArray.filter { $0.scriptId == scriptId }
            let scriptSessionIds = Set(scriptSessions.map { $0.id })
            let scriptReports = userPerformanceReports.filter { scriptSessionIds.contains($0.sessionID) }
            
            guard !scriptReports.isEmpty else {
                DispatchQueue.main.async {
                    self.overallImprovement = 0
                }
                return 0
            }
            
            // Calculate average scores from script's reports
            var totalScore = 0.0
            
            for report in scriptReports {
                let fillerWordsScore = max(0, 100 - (Double(report.fillerWords.count) * 5))
                let missingWordsScore = max(0, 100 - (Double(report.missingWords.count) * 5))
                let paceScore = min(100, Double(report.wordsPerMinute))
                
                let reportScore = (fillerWordsScore * 0.3 +
                                 missingWordsScore * 0.3 +
                                 paceScore * 0.4)
                
                totalScore += reportScore
            }
            
            let averageScore = totalScore / Double(scriptReports.count)
            
            // Update the published property
            DispatchQueue.main.async {
                self.overallImprovement = averageScore
            }
            
            return averageScore
        }

        func calculateRecentImprovement(for scriptId: UUID? = nil) -> Double {
            guard let scriptId = scriptId else { return 0 }
            
            // Filter reports for the specific script
            let scriptSessions = sessionsArray.filter { $0.scriptId == scriptId }
            let scriptSessionIds = Set(scriptSessions.map { $0.id })
            let scriptReports = userPerformanceReports.filter { scriptSessionIds.contains($0.sessionID) }
            .sorted { $0.sessionID > $1.sessionID }
            
            guard scriptReports.count >= 2 else { return 0 }
            
            let latest = scriptReports[0]
            let previous = scriptReports[1]
            
            func calculateScore(for report: PerformanceReport) -> Double {
                let fillerWordsScore = max(0, 100 - (Double(report.fillerWords.count) * 5))
                let missingWordsScore = max(0, 100 - (Double(report.missingWords.count) * 5))
                let paceScore = min(100, Double(report.wordsPerMinute))
                
                return (fillerWordsScore * 0.3 + missingWordsScore * 0.3 + paceScore * 0.4)
            }
            
            let latestScore = calculateScore(for: latest)
            let previousScore = calculateScore(for: previous)
            let improvement = ((latestScore - previousScore) / previousScore) * 100
            return max(-100, min(100, improvement))
        }

        func calculateFillerWordsImprovement(for scriptId: UUID? = nil) -> Double {
            let targetScriptId = scriptId ?? scripts.first?.id
            
            guard let scriptId = targetScriptId else { return 0 }
            
            let scriptSessions = sessionsArray.filter { $0.scriptId == scriptId }
            let scriptSessionIds = Set(scriptSessions.map { $0.id })
            let scriptReports = userPerformanceReports.filter { scriptSessionIds.contains($0.sessionID) }
                .sorted { $0.sessionID > $1.sessionID }
            
            guard scriptReports.count >= 2 else { return 0 }
            
            let latest = scriptReports[0]
            let previous = scriptReports[1]
            
            let latestScore = max(0, 100 - (Double(latest.fillerWords.count) * 5))
            let previousScore = max(0, 100 - (Double(previous.fillerWords.count) * 5))
            
            let improvement = ((latestScore - previousScore) / previousScore) * 100
            return max(-100, min(100, improvement))
        }
        
        func calculateMissingWordsImprovement(for scriptId: UUID? = nil) -> Double {
            let targetScriptId = scriptId ?? scripts.first?.id
            
            guard let scriptId = targetScriptId else { return 0 }
            
            let scriptSessions = sessionsArray.filter { $0.scriptId == scriptId }
            let scriptSessionIds = Set(scriptSessions.map { $0.id })
            let scriptReports = userPerformanceReports.filter { scriptSessionIds.contains($0.sessionID) }
                .sorted { $0.sessionID > $1.sessionID }
            
            guard scriptReports.count >= 2 else { return 0 }
            
            let latest = scriptReports[0]
            let previous = scriptReports[1]
            
            let latestScore = max(0, 100 - (Double(latest.missingWords.count) * 5))
            let previousScore = max(0, 100 - (Double(previous.missingWords.count) * 5))
            
            let improvement = ((latestScore - previousScore) / previousScore) * 100
            return max(-100, min(100, improvement))
        }
        
        func calculatePronunciationImprovement(for scriptId: UUID? = nil) -> Double {
            let targetScriptId = scriptId ?? scripts.first?.id
            
            guard let scriptId = targetScriptId else { return 0 }
            
            let scriptSessions = sessionsArray.filter { $0.scriptId == scriptId }
            let scriptSessionIds = Set(scriptSessions.map { $0.id })
            let scriptReports = userPerformanceReports.filter { scriptSessionIds.contains($0.sessionID) }
                .sorted { $0.sessionID > $1.sessionID }
            
            guard scriptReports.count >= 2 else { return 0 }
            
            let latest = scriptReports[0]
            let previous = scriptReports[1]
            
            // Assuming pronunciation score is based on words per minute as a proxy
            let latestScore = min(100, Double(latest.wordsPerMinute))
            let previousScore = min(100, Double(previous.wordsPerMinute))
            
            let improvement = ((latestScore - previousScore) / previousScore) * 100
            return max(-100, min(100, improvement))
        }
        
        func updateUserProfileImage(_ imageURL: String) {
            if var currentUser = SupabaseManager.shared.currentUser {
                currentUser.profileImageURL = imageURL
                SupabaseManager.shared.currentUser = currentUser
            }
        }
    }



