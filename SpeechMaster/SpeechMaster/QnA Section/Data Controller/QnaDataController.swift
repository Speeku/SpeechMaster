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
