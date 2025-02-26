//import Foundation
//
//// Represents a single Q&A session
//struct QnASession1: Identifiable {
//    let id: UUID
//    let title: String
//    let createdAt: Date
//    var questions: [Question]
//    let scriptId: UUID
//    var status: SessionStatus
//    var duration: TimeInterval
//    var confidence: Double
//    
//    enum SessionStatus: String {
//        case notStarted = "Not Started"
//        case inProgress = "In Progress"
//        case completed = "Completed"
//        
//        var color: String {
//            switch self {
//            case .notStarted: return "7D7C7C"
//            case .inProgress: return "007AFF"
//            case .completed: return "34C759"
//            }
//        }
//    }
//}
//
//// Represents a single question in a Q&A session
//struct Question: Identifiable {
//    let id: UUID
//    let text: String
//    var answer: String?
//    var isAnswered: Bool
//    var confidence: Double
//    var feedback: [Feedback]
//    var duration: TimeInterval?
//    
//    struct Feedback: Identifiable {
//        let id: UUID
//        let category: FeedbackCategory
//        let message: String
//        let severity: Severity
//        
//        enum FeedbackCategory: String {
//            case clarity = "Clarity"
//            case confidence = "Confidence"
//            case content = "Content"
//            case delivery = "Delivery"
//            case timing = "Timing"
//        }
//        
//        enum Severity: String {
//            case positive = "Positive"
//            case suggestion = "Suggestion"
//            case improvement = "Needs Improvement"
//            
//            var color: String {
//                switch self {
//                case .positive: return "34C759"
//                case .suggestion: return "007AFF"
//                case .improvement: return "FF3B30"
//                }
//            }
//        }
//    }
//}
//
//// Extension to create sample data for previews
//extension QnASession {
//    static var sampleData: [QnASession1] {
//        [
//            QnASession1(
//                id: UUID(),
//                title: "Technical Interview Practice",
//                createdAt: Date(),
//                questions: [
//                    Question(
//                        id: UUID(),
//                        text: "What are your strengths in public speaking?",
//                        answer: "I excel at organizing complex information into clear, engaging presentations.",
//                        isAnswered: true,
//                        confidence: 0.85,
//                        feedback: [
//                            Question.Feedback(
//                                id: UUID(),
//                                category: .confidence,
//                                message: "Great eye contact and posture",
//                                severity: .positive
//                            ),
//                            Question.Feedback(
//                                id: UUID(),
//                                category: .delivery,
//                                message: "Consider varying your pace for emphasis",
//                                severity: .suggestion
//                            )
//                        ],
//                        duration: 120
//                    ),
//                    Question(
//                        id: UUID(),
//                        text: "How do you handle unexpected questions?",
//                        answer: nil,
//                        isAnswered: false,
//                        confidence: 0,
//                        feedback: [],
//                        duration: nil
//                    )
//                ],
//                scriptId: UUID(),
//                status: .inProgress,
//                duration: 300,
//                confidence: 0.75
//            ),
//            QnASession1(
//                id: UUID(),
//                title: "Product Pitch Q&A",
//                createdAt: Date().addingTimeInterval(-86400),
//                questions: [
//                    Question(
//                        id: UUID(),
//                        text: "What makes your product unique?",
//                        answer: "Our product combines AI with human expertise.",
//                        isAnswered: true,
//                        confidence: 0.92,
//                        feedback: [
//                            Question.Feedback(
//                                id: UUID(),
//                                category: .content,
//                                message: "Excellent use of specific examples",
//                                severity: .positive
//                            )
//                        ],
//                        duration: 90
//                    )
//                ],
//                scriptId: UUID(),
//                status: .completed,
//                duration: 180,
//                confidence: 0.92
//            )
//        ]
//    }
//} 
