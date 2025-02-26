import Foundation

struct AIGeneratedQuestion: Identifiable {
    let id: UUID
    let question: String
    let suggestedAnswer: String
    var userAnswer: String?
    var confidence: Double?
    var feedback: QuestionFeedback?
    
    struct QuestionFeedback {
        let strengths: [String]
        let improvements: [String]
        let similarityScore: Double
        let clarity: Double
        let completeness: Double
    }
}

struct AIQnASession: Identifiable {
    let id: UUID
    let scriptId: UUID
    let scriptTitle: String
    let createdAt: Date
    var questions: [AIGeneratedQuestion]
    var currentQuestionIndex: Int
    var status: SessionStatus
    
    enum SessionStatus {
        case generating
        case inProgress
        case completed
    }
    
    var isCompleted: Bool {
        currentQuestionIndex >= questions.count
    }
    
    var currentQuestion: AIGeneratedQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var averageConfidence: Double {
        let answeredQuestions = questions.compactMap { $0.confidence }
        guard !answeredQuestions.isEmpty else { return 0 }
        return answeredQuestions.reduce(0, +) / Double(answeredQuestions.count)
    }
}

// Sample data for previews
extension AIQnASession {
    static var preview: AIQnASession {
        AIQnASession(
            id: UUID(),
            scriptId: UUID(),
            scriptTitle: "Product Launch Presentation",
            createdAt: Date(),
            questions: [
                AIGeneratedQuestion(
                    id: UUID(),
                    question: "How would you describe the target audience for your product?",
                    suggestedAnswer: "Our product targets tech-savvy professionals aged 25-45 who value efficiency and innovation in their daily work. These individuals are often in management positions or growing their careers, looking for solutions that can streamline their workflow and enhance productivity.",
                    userAnswer: "The product is aimed at professionals who want to improve their work efficiency. We're focusing on people who use technology regularly and need better tools for their job.",
                    confidence: 0.85,
                    feedback: AIGeneratedQuestion.QuestionFeedback(
                        strengths: [
                            "Clear identification of professional focus",
                            "Mentioned key user needs"
                        ],
                        improvements: [
                            "Could specify age demographic",
                            "Add more details about user positions/roles"
                        ],
                        similarityScore: 0.78,
                        clarity: 0.85,
                        completeness: 0.75
                    )
                ),
                AIGeneratedQuestion(
                    id: UUID(),
                    question: "What sets your product apart from existing solutions?",
                    suggestedAnswer: "Our product differentiates itself through its AI-powered automation capabilities, intuitive user interface, and seamless integration with existing workflows. We've also prioritized data security and real-time collaboration features.",
                    userAnswer: nil,
                    confidence: nil,
                    feedback: nil
                )
            ],
            currentQuestionIndex: 0,
            status: .inProgress
        )
    }
} 