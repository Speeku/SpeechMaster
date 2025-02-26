//import Foundation
//import SwiftUI
//
//class QnAViewModel: ObservableObject {
//    @Published var sessions: [QnASession1] = []
//    @Published var currentSession: QnASession1?
//    @Published var searchText: String = ""
//    @Published var selectedFilter: SessionFilter = .all
//    @Published var isRecording = false
//    @Published var showingNewSessionSheet = false
//    @Published var showingQuestionSheet = false
//    @Published var currentQuestion: Question?
//    @Published var recordingDuration: TimeInterval = 0
//    @Published var audioLevel: Double = 0
//    private var timer: Timer?
//    
//    enum SessionFilter: String, CaseIterable {
//        case all = "All"
//        case inProgress = "In Progress"
//        case completed = "Completed"
//    }
//    
//    // MARK: - Computed Properties
//    
//    var filteredSessions: [QnASession1] {
//        let filtered = sessions.filter { session in
//            if searchText.isEmpty {
//                return true
//            }
//            return session.title.localizedCaseInsensitiveContains(searchText)
//        }
//        
//        switch selectedFilter {
//        case .all:
//            return filtered
//        case .inProgress:
//            return filtered.filter { $0.status == .inProgress }
//        case .completed:
//            return filtered.filter { $0.status == .completed }
//        }
//    }
//    
//    var currentProgress: Double {
//        guard let session = currentSession else { return 0 }
//        let answeredCount = session.questions.filter { $0.isAnswered }.count
//        return Double(answeredCount) / Double(session.questions.count)
//    }
//    
//    var averageConfidence: Double {
//        guard let session = currentSession else { return 0 }
//        let answeredQuestions = session.questions.filter { $0.isAnswered }
//        guard !answeredQuestions.isEmpty else { return 0 }
//        return answeredQuestions.reduce(0) { $0 + $1.confidence } / Double(answeredQuestions.count)
//    }
//    
//    // MARK: - Initialization
//    
//    init(previewData: Bool = false) {
//        if previewData {
//            sessions = QnASession.sampleData
//        }
//        loadSessions()
//    }
//    
//    // MARK: - Session Management
//    
//    func loadSessions() {
//        // TODO: Load sessions from DataController
//        // For now, using sample data
//        if sessions.isEmpty {
//            sessions = QnASession.sampleData
//        }
//    }
//    
//    func createNewSession(title: String, scriptId: UUID, questions: [Question]) {
//        let newSession = QnASession1(
//            id: UUID(),
//            title: title,
//            createdAt: Date(),
//            questions: questions,
//            scriptId: scriptId,
//            status: .notStarted,
//            duration: 0,
//            confidence: 0
//        )
//        sessions.append(newSession)
//        currentSession = newSession
//    }
//    
//    func startSession() {
//        guard var session = currentSession else { return }
//        session.status = .inProgress
//        updateSession(session)
//        startTimer()
//    }
//    
//    func completeSession() {
//        guard var session = currentSession else { return }
//        session.status = .completed
//        updateSession(session)
//        stopTimer()
//    }
//    
//    private func updateSession(_ session: QnASession1) {
//        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
//            sessions[index] = session
//            currentSession = session
//        }
//    }
//    
//    // MARK: - Recording Management
//    
//    func startRecording() {
//        isRecording = true
//        startTimer()
//        // TODO: Implement actual audio recording
//    }
//    
//    func stopRecording() {
//        isRecording = false
//        stopTimer()
//        // TODO: Implement audio recording stop
//    }
//    
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            self?.recordingDuration += 0.1
//            // Simulate audio level changes
//            self?.audioLevel = Double.random(in: 0.1...0.9)
//        }
//    }
//    
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    // MARK: - Question Management
//    
//    func updateQuestion(_ question: Question) {
//        guard var session = currentSession else { return }
//        if let index = session.questions.firstIndex(where: { $0.id == question.id }) {
//            session.questions[index] = question
//            updateSession(session)
//        }
//    }
//    
//    func addFeedback(_ feedback: Question.Feedback, to question: Question) {
//        var updatedQuestion = question
//        updatedQuestion.feedback.append(feedback)
//        updateQuestion(updatedQuestion)
//    }
//} 
