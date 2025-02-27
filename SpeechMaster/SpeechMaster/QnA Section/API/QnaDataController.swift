////
////  DataController.swift
////  A
////
////  Created by Arnav Chauhan on 14/02/25.
////
//
//import Foundation
//import GoogleGenerativeAI
//
//class QnaDataController {
//    
//    static let shared = QnaDataController()
//    private init() {
//        updateScript() // Add this to initialize script properly
//    }
//    
//  //  var questions: [QnAQuestion] = []
//    var questions  = HomeViewModel.shared.qnaQuestions
//    var isQuestionsLoaded: Bool = false
//    
//  //  private var count: Int{
//       //return questions.count
//   // }
//    private var count : Int{
//        return HomeViewModel.shared.qnaQuestions.count
//    }
//    var script: String = "" {
//        didSet {
//            print("📝 QnaDataController - Script Updated")
//            print("📊 Word Count: \(script.split(separator: " ").count)")
//        }
//    }
//    // Add the model property
//    private let model = GenerativeModel(name: "models/gemini-1.5-flash", apiKey: APIKey.default)
//    
//    func updateScript() {
//        // Clear previous script first
//        script = ""
//        questions = []
//        
//        let newScript = HomeViewModel.shared.getScriptText(for: HomeViewModel.shared.currentScriptID)
//        print("🔄 Updating script from HomeViewModel")
//        print("📝 New Script Content: \(newScript)")
//        
//        // Clean the script before storing
//        script = newScript.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        // Debug print
//        let wordCount = script.split(separator: " ").filter { !$0.isEmpty }.count
//        print("📊 Clean Script Word Count: \(wordCount)")
//    }
//    
//    // Add this method to force script refresh
//    func refreshScript() {
//        updateScript()
//    }
//    
//    func setQuestionNumber() -> Int {
//        let words = script.split(separator: " ").count
//        // Require minimum word count
//        guard words >= 50 else { return 0 } // Return 0 to indicate script is too short
//        
//        switch words {
//        case 50...99: return 3     // Add a new case for very short scripts
//        case 100...199: return 5
//        case 200...299: return 7
//        case 300...399: return 10
//        case 400...: return 15
//        default: return 0          // Return 0 for invalid cases
//        }
//    }
//    
//    func updateUserAnswer(at index: Int, with answer: String, timeTaken: TimeInterval = 0) {
//        guard index < questions.count else { return }
//        
//        let question = questions[index]
//        print("⏱️ DataController - Updating question \(index) with time: \(timeTaken)")
//        
//        questions[index] = QnAQuestion(
//            id: question.id,
//            qna_session_Id: question.qna_session_Id,
//            questionText: question.questionText,
//            userAnswer: answer,
//            suggestedAnswer: question.suggestedAnswer,
//            timeTaken: timeTaken
//        )
//        
//        print("⏱️ DataController - Verified time for question \(index): \(questions[index].timeTaken)")
//    }
//    
//    func parseQuestionsAndAnswers(from response: String, sessionId: UUID) -> [QnAQuestion] {
//        print("🔍 Starting to parse response")
//        var parsedQuestions = [QnAQuestion]()
//        
//        // Split into components
//        let components = response.components(separatedBy: "\n\n")
//        var currentQuestion: String?
//        var currentAnswer: String?
//        
//        print("📝 Parsing components: \(components.count)")
//        
//        for component in components {
//            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            if trimmed.lowercased().contains("question") {
//                // Save previous Q&A pair if exists
//                if let q = currentQuestion, let a = currentAnswer {
//                    let question = QnAQuestion(
//                        id: UUID(),
//                        qna_session_Id: sessionId,
//                        questionText: q,
//                        userAnswer: "",
//                        suggestedAnswer: a,
//                        timeTaken: 0
//                    )
//                    parsedQuestions.append(question)
//                    print("✅ Added Q&A pair")
//                }
//                
//                // Extract new question
//                currentQuestion = trimmed.replacingOccurrences(of: #"Question\s*\d*\s*:"#, with: "", options: .regularExpression)
//                    .trimmingCharacters(in: .whitespacesAndNewlines)
//                currentAnswer = nil
//                
//            } else if trimmed.lowercased().contains("answer") {
//                // Extract answer
//                currentAnswer = trimmed.replacingOccurrences(of: #"Answer\s*\d*\s*:"#, with: "", options: .regularExpression)
//                    .trimmingCharacters(in: .whitespacesAndNewlines)
//            }
//        }
//        
//        // Add final Q&A pair if exists
//        if let q = currentQuestion, let a = currentAnswer {
//            let question = QnAQuestion(
//                id: UUID(),
//                qna_session_Id: sessionId,
//                questionText: q,
//                userAnswer: "",
//                suggestedAnswer: a,
//                timeTaken: 0
//            )
//            parsedQuestions.append(question)
//        }
//        
//        print("✅ Successfully parsed \(parsedQuestions.count) Q&A pairs")
//        return parsedQuestions
//    }
//
//    func generateQuestionsAndAnswers(from script: String, completion: @escaping ([QnAQuestion]?) -> Void) {
//        print("📊 Processing script with \(script.split(separator: " ").count) words")
//        
//        // First verify we have script content
//        guard !script.isEmpty else {
//            print("❌ Empty script received")
//            completion(nil)
//            return
//        }
//        
//        let prompt = """
//        Based on the following script, generate exactly \(setQuestionNumber()) challenging questions:
//        
//        \(script)
//        
//        Format as a numbered list:
//        1. First question
//        2. Second question
//        etc.
//        """
//        
//        Task {
//            do {
//                let result = try await model.generateContent(prompt)
//                
//                if let responseText = result.text {
//                    print("📝 Response received: \(responseText)")
//                    
//                    // Create session ID
//                    let sessionId = UUID()
//                    
//                    // Parse questions
//                    let questions = parseQuestionsAndAnswers(from: responseText, sessionId: sessionId)
//                    
//                    print("📊 Parsed \(questions.count) questions")
//                    
//                    if !questions.isEmpty {
//                        // Store questions locally
//                        self.questions = questions
//                        print("✅ Successfully generated questions")
//                        completion(questions)
//                    } else {
//                        print("❌ No questions parsed from response")
//                        completion(nil)
//                    }
//                } else {
//                    print("❌ Empty response from API")
//                    completion(nil)
//                }
//            } catch {
//                print("❌ Generation error: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//    }
//
//}
//
//  DataController.swift
//  A
//
//  Created by Arnav Chauhan on 14/02/25.
//

import Foundation
import GoogleGenerativeAI

class QnaDataController {
    
    static let shared = QnaDataController()
    private init() {
        updateScript() // Add this to initialize script properly
    }
    
  //  var questions: [QnAQuestion] = []
    var questions  = HomeViewModel.shared.qnaQuestions
    var isQuestionsLoaded: Bool = false
    
  //  private var count: Int{
       //return questions.count
   // }
    private var count : Int{
        return HomeViewModel.shared.qnaQuestions.count
    }
    var script: String = "" {
        didSet {
            print("📝 QnaDataController - Script Updated")
            print("📊 Word Count: \(script.split(separator: " ").count)")
        }
    }
    // Add the model property
    private let model = GenerativeModel(name: "models/gemini-1.5-flash", apiKey: APIKey.default)
    
    func updateScript() {
        // Clear previous script first
        script = ""
        questions = []
        
        let newScript = HomeViewModel.shared.getScriptText(for: HomeViewModel.shared.currentScriptID)
        print("🔄 Updating script from HomeViewModel")
        print("📝 New Script Content: \(newScript)")
        
        // Clean the script before storing
        script = newScript.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Debug print
        let wordCount = script.split(separator: " ").filter { !$0.isEmpty }.count
        print("📊 Clean Script Word Count: \(wordCount)")
    }
    
    // Add this method to force script refresh
    func refreshScript() {
        updateScript()
    }
    
    func setQuestionNumber() -> Int {
        let words = script.split(separator: " ").count
        // Require minimum word count
        guard words >= 50 else { return 0 } // Return 0 to indicate script is too short
        
        switch words {
        case 50...99: return 3     // Add a new case for very short scripts
        case 100...199: return 5
        case 200...299: return 7
        case 300...399: return 10
        case 400...: return 15
        default: return 0          // Return 0 for invalid cases
        }
    }
    
    func updateUserAnswer(at index: Int, with answer: String, timeTaken: TimeInterval = 0) {
        guard index < questions.count else { return }
        
        let question = questions[index]
        print("⏱️ DataController - Updating question \(index) with time: \(timeTaken)")
        
        questions[index] = QnAQuestion(
            id: question.id,
            qna_session_Id: question.qna_session_Id,
            questionText: question.questionText,
            userAnswer: answer,
            suggestedAnswer: question.suggestedAnswer,
            timeTaken: timeTaken
        )
        
        print("⏱️ DataController - Verified time for question \(index): \(questions[index].timeTaken)")
    }
    
     func parseQuestionsAndAnswers(from response: String, sessionId: UUID) -> [QnAQuestion] {
        print("🔍 Starting to parse response")
        var questions: [QnAQuestion] = []
        
        // Split by "Question:" to get question-answer pairs
        let pairs = response.components(separatedBy: "Question:")
            .filter { !$0.isEmpty }
        
        print("📝 Found \(pairs.count) potential Q&A pairs")
        
        for pair in pairs {
            // Split each pair into question and answer
            let components = pair.components(separatedBy: "Answer:")
            guard components.count == 2 else { continue }
            
            let questionText = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let answerText = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("📝 Processing Q: \(questionText)")
            print("📝 Processing A: \(answerText)")
            
            let question = QnAQuestion(
                id: UUID(),
                qna_session_Id: sessionId,
                questionText: questionText,
                userAnswer: "",
                suggestedAnswer: answerText,
                timeTaken: 0
            )
            questions.append(question)
        }
        
        print("✅ Successfully parsed \(questions.count) questions with answers")
        return questions
    }

    func generateQuestionsAndAnswers(from script: String, completion: @escaping ([QnAQuestion]?) -> Void) {
        print("📊 Processing script with \(script.split(separator: " ").count) words")
        
        let prompt = """
        Generate exactly \(setQuestionNumber()) questions and answers. Format EXACTLY as shown:

        Question: [Your question here]
        Answer: [Your detailed answer here]

        Question: [Your next question]
        Answer: [Your next answer]

        (and so on...)

        Use this script:
        \(script)
        """
        
        Task {
            do {
                // Only try once
                let result = try await model.generateContent(prompt)
                if let responseText = result.text {
                    print("📝 Raw API Response:\n\(responseText)")
                    let sessionId = UUID()  // Create new session ID
                    let questions = parseQuestionsAndAnswers(from: responseText, sessionId: sessionId)
                    
                    if !questions.isEmpty {
                        print("✅ Successfully generated \(questions.count) questions")
                        self.questions = questions
                        completion(questions)
                    } else {
                        print("❌ No questions parsed")
                        completion(nil)
                    }
                }
            } catch {
                print("❌ Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
