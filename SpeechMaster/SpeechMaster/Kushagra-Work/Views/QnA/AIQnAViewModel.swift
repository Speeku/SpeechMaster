import Foundation
import SwiftUI

@MainActor
class AIQnAViewModel: ObservableObject {
    @Published var session: AIQnASession?
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var audioLevel: Double = 0
    @Published var showingCompletionSheet = false
    @Published var isGeneratingQuestions = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    private let dataController = HomeViewModel.shared
    
    // MARK: - Session Management
    
    func startNewSession(scriptId: UUID, scriptTitle: String) async {
        isGeneratingQuestions = true
        // Simulate API call to generate questions
        do {
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds delay
            let questions = generateSampleQuestions() // Replace with actual API call
            
            session = AIQnASession(
                id: UUID(),
                scriptId: scriptId,
                scriptTitle: scriptTitle,
                createdAt: Date(),
                questions: questions,
                currentQuestionIndex: 0,
                status: .inProgress
            )
            isGeneratingQuestions = false
        } catch {
            errorMessage = "Failed to generate questions. Please try again."
            isGeneratingQuestions = false
        }
    }
    
    func nextQuestion() {
        guard var currentSession = session else { return }
        currentSession.currentQuestionIndex += 1
        
        if currentSession.isCompleted {
            currentSession.status = .completed
            showingCompletionSheet = true
        }
        
        session = currentSession
    }
    
    // MARK: - Recording Management
    
    func startRecording() {
        isRecording = true
        transcribedText = ""
        startAudioLevelSimulation()
        // TODO: Implement actual recording and transcription
    }
    
    func stopRecording() {
        isRecording = false
        stopAudioLevelSimulation()
        
        // Update current question with transcribed answer
        guard var currentSession = session,
              let currentQuestion = currentSession.currentQuestion else { return }
        
        var updatedQuestion = currentQuestion
        updatedQuestion.userAnswer = transcribedText
        updatedQuestion.confidence = Double.random(in: 0.7...0.95) // Replace with actual confidence
        
        // Simulate feedback generation
        updatedQuestion.feedback = generateFeedback(
            userAnswer: transcribedText,
            suggestedAnswer: currentQuestion.suggestedAnswer
        )
        
        // Update session
        currentSession.questions[currentSession.currentQuestionIndex] = updatedQuestion
        session = currentSession
    }
    
    private func startAudioLevelSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.audioLevel = Double.random(in: 0.1...0.9)
            
            // Simulate live transcription
            if let self = self {
                self.transcribedText += " " + self.generateRandomWord()
            }
        }
    }
    
    private func stopAudioLevelSimulation() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Helper Functions
    
    private func generateSampleQuestions() -> [AIGeneratedQuestion] {
        // Replace with actual API call to generate questions
        [
            AIGeneratedQuestion(
                id: UUID(),
                question: "What is the main value proposition of your product?",
                suggestedAnswer: "Our product's main value proposition is its ability to increase productivity by 40% through AI-powered automation, while maintaining enterprise-grade security and an intuitive user experience that requires minimal training.",
                userAnswer: nil,
                confidence: nil,
                feedback: nil
            ),
            AIGeneratedQuestion(
                id: UUID(),
                question: "How do you plan to scale your solution?",
                suggestedAnswer: "We have a three-phase scaling strategy: First, expanding our core market presence, then introducing enterprise features, and finally launching international operations with localized solutions.",
                userAnswer: nil,
                confidence: nil,
                feedback: nil
            )
        ]
    }
    
    private func generateFeedback(userAnswer: String, suggestedAnswer: String) -> AIGeneratedQuestion.QuestionFeedback {
        // Replace with actual feedback generation logic
        AIGeneratedQuestion.QuestionFeedback(
            strengths: [
                "Good structure and clarity",
                "Covered key points effectively"
            ],
            improvements: [
                "Could provide more specific examples",
                "Consider adding quantitative data"
            ],
            similarityScore: Double.random(in: 0.7...0.9),
            clarity: Double.random(in: 0.7...0.9),
            completeness: Double.random(in: 0.7...0.9)
        )
    }
    
    private func generateRandomWord() -> String {
        // Simulate transcription by adding random words
        let words = ["the", "product", "features", "innovative", "solution", "market", "customers", "value", "growth"]
        return words.randomElement() ?? ""
    }
} 
