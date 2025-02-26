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
        var parsedQuestions = [QnAQuestion]()
        
        // Split by "Question:" but keep the delimiter
        let components = response.components(separatedBy: "Question:")
            .filter { !$0.isEmpty }  // Remove empty strings
        
        print("📊 Found \(components.count) potential question components")
        
        for component in components {
            // Split by "Answer:" but keep the delimiter
            let parts = component.components(separatedBy: "Answer:")
            
            if parts.count >= 2 {
                let questionText = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let suggestedAnswerText = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !questionText.isEmpty && !suggestedAnswerText.isEmpty {
                    let question = QnAQuestion(
                        id: UUID(),
                        qna_session_Id: sessionId,
                        questionText: questionText,
                        userAnswer: "",
                        suggestedAnswer: suggestedAnswerText,
                        timeTaken: 0
                    )
                    parsedQuestions.append(question)
                    print("✅ Parsed question: \(questionText)")
                }
            }
        }
        
        print("📝 Successfully parsed \(parsedQuestions.count) questions")
        return parsedQuestions
    }

    func generateQuestionsAndAnswers(from inputScript: String, completion: @escaping ([QnAQuestion]?) -> Void) {
        // Validate script first
        let wordCount = inputScript.split(separator: " ").filter { !$0.isEmpty }.count
        print("📝 Processing script with \(wordCount) words")
        
        guard wordCount >= 50 else {
            print("❌ Script too short")
            completion(nil)
            return
        }
        
        let prompt = """
        Generate \(setQuestionNumber()) clear and concise questions about this script:
        
        \(inputScript)
        
        Format each question as a numbered list, with just the question text (no asterisks or special formatting).
        Example format:
        1. What is the main theme of this speech?
        2. How does the speaker engage the audience?
        
        Keep questions focused on content, delivery, and structure.
        """
        
        Task {
            do {
                // Create a chat
                let chat = model.startChat()
                
                // Generate content with retry
                for attempt in 1...3 {
                    do {
                        print("🔄 Attempt \(attempt) to generate questions")
                        let response = try await chat.sendMessage(prompt)
                        
                        if let responseText = response.text {
                            print("📝 Raw API Response:")
                            print(responseText)
                            
                            let sessionId = UUID()
                            let questions = parseQuestionsAndAnswers(from: responseText, sessionId: sessionId)
                            
                            if !questions.isEmpty {
                                print("✅ Successfully generated \(questions.count) questions")
                                // Update local questions array
                                self.questions = questions
                                completion(questions)
                                return
                            }
                        }
                        
                        print("⚠️ Empty response, retrying...")
                    } catch {
                        print("❌ Error on attempt \(attempt): \(error.localizedDescription)")
                        if attempt == 3 {
                            throw error
                        }
                        try await Task.sleep(nanoseconds: UInt64(1_000_000_000))
                    }
                }
                
                print("❌ All attempts failed")
                completion(nil)
                
            } catch {
                print("❌ Final error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
