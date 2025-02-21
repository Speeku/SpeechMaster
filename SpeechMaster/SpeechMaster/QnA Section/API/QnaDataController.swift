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
    private init(){}
    
    var questions: [QnAQuestion] = []
    var isQuestionsLoaded: Bool = false
    
    private var count: Int{
       return questions.count
    }
     
//Title: Our Loyal Companions: A Day in the Life of Dogs
//
//Scene 1: Morning Routine
//Setting: A cozy living room. Sunlight streams through a window, illuminating a fluffy white dog named Max, who is stretched out on a soft rug.
//
//Narrator: (V.O.) "Meet Max, a four-year-old Golden Retriever who lives with the Sharma family. Every morning, he greets the day with enthusiasm."
//
//Max yawns, stretches, and trots towards the kitchen, where Mrs. Sharma is preparing breakfast.
//
//Mrs. Sharma: "Good morning, Max! Ready for breakfast?"
//
//Max wags his tail excitedly as she places his bowl of kibble on the floor.
//
//Scene 2: A Day of Adventure
//Setting: A busy park filled with children playing, joggers, and other dogs.
//
//Max runs across the grass, chasing a frisbee thrown by Mr. Sharma. Other dogs join in, barking joyfully.
//
//Narrator: (V.O.) "Dogs like Max thrive on social interaction and play. The park is their favourite place to make new friends and burn off energy."
//
//Max and his friends play fetch, chase, and wrestle in the sun.
//
//Scene 3: Afternoon Nap
//Setting: The Sharma's living room. Max lies on the couch, peacefully napping.
//
//Narrator: (V.O.) "After a morning of excitement, Max enjoys a well-deserved nap. Dogs, much like us, need rest to replenish their energy."
//
//The camera zooms in on Max's face, his eyes fluttering with dreams of chasing squirrels.
//
//Scene 4: Evening Walk
//Setting: A quiet neighbourhood street at sunset.
//
//Mr. Sharma and Max walk down the street, Max sniffing every bush and tree along the way.
//
//Mr. Sharma: "You're such a good boy, Max. Always ready for adventure."
//
//Narrator: (V.O.) "Evening walks are a time for bonding and exercise, helping dogs like Max stay healthy and happy."
//
//Scene 5: Nighttime Routine
//Setting: The Sharmas' living room, now dimly lit and cozy.
//
//Max curls up in his favourite spot near the fireplace as the family gathers to watch TV.
//
//Narrator: (V.O.) "As the day ends, Max finds comfort in the love and warmth of his family."
//
//The camera pans out to show the family together, Max contently resting at their feet.
//
//Narrator: (V.O.) "In the eyes of a dog like Max, every day is an adventure, filled with love, loyalty, and joy."
//
//Fade Out.
//
//The End.
//"""
    var script  : String = """
    Here's a short script about alligators for an educational or documentary-style video.
    
    ---

    **Title: The Alligator - A Prehistoric Predator**

    **[Opening Scene]**
    *(Soft instrumental music plays. A misty swamp at dawn, water rippling gently.)*

    **Narrator:**
    "Deep within the murky waters of swamps and rivers, an ancient predator lurks. With eyes just above the surface, it watches… waits… and then—strikes!"

    **[Cut to a close-up of an alligator's eyes emerging from the water.]**

    **Narrator:**
    "The alligator—one of Earth's oldest surviving reptiles—has been around for over 37 million years. A living fossil, built for stealth and power."

    **[Scene: A slow-motion shot of an alligator lunging at its prey.]**

    **Narrator:**
    "With a bite force of nearly 3,000 pounds per square inch, an alligator's jaws can crush bones in an instant. But despite their fearsome reputation, these reptiles play a crucial role in their ecosystem."

    **[Scene: An alligator basking in the sun, birds perched nearby.]**

    **Narrator:**
    "By digging holes in the wetlands, alligators create habitats for fish, insects, and other wildlife. Their presence maintains the delicate balance of nature."

    **[Scene: A mother alligator gently carrying her hatchlings in her mouth.]**

    **Narrator:**
    "And they're not just fierce hunters—they're protective parents. A mother alligator guards her young for months, ensuring they survive in the wild."

    **[Scene: A wide shot of an alligator slipping back into the water.]**

    **Narrator:**
    "Feared, respected, and essential to their environment—the alligator remains a true symbol of nature's raw power."

    **[Closing Scene: The swamp at dusk, an alligator's eyes glowing above the water.]**

    **Narrator:**
    "So next time you see those watchful eyes in the water… remember, you're looking at a survivor of the prehistoric world."

    *(Music fades, screen fades to black.)*

    ---
"""

    // Add the model property
    private let model = GenerativeModel(name: "models/gemini-2.0-flash-lite-preview-02-05", apiKey: APIKey.default)
    
    func setQuestionNumber() -> Int {
        let words = script.split(separator: " ").count
//        switch words {
//        case 100...199: return 5
//        case 200...299: return 7
//        case 300...399: return 10
//        case 400...: return 15
//        default: return 5
        
        //}
    return 1
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
        var parsedQuestions = [QnAQuestion]()
        
        let components = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "Question:")
        
        for component in components.dropFirst() {
            let parts = component.split(separator: "Answer:")
            
            if parts.count >= 2 {
                let questionText = String(parts[0])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let suggestedAnswerText = String(parts[1])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
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
                }
            }
        }
        
        self.questions = parsedQuestions
        return parsedQuestions
    }

    func fillQnaData() {
        
    }

    func generateQuestionsAndAnswers(from script: String, completion: @escaping ([QnAQuestion]?) -> Void) {
        // Generate a random perspective for more variety
        let perspectives = [
            "investors evaluating market potential",
            "technical experts analyzing feasibility",
            "potential customers considering adoption",
            "industry veterans examining business model",
            "competition analysts studying differentiation"
        ]
        let randomPerspective = perspectives.randomElement() ?? "investors"
        
        let prompt = """
              Based on the following script, generate exactly \(setQuestionNumber()) unique and challenging questions from the perspective of \(randomPerspective). Make sure these questions are different from typical questions by focusing on unexpected angles and deep insights.

        ### **Instructions:**
        - Create questions that challenge different aspects of the pitch
        - Focus on \(randomPerspective)
        - Avoid basic or common questions
        - Each question should be unique and thought-provoking
        - Questions should require detailed, analytical responses
        - Mix strategic, technical, and market-focused questions
        
        ### **Example Unique Questions:**
        ✅ "How would your solution adapt if [unexpected market change] occurred?"
        ✅ "What counterintuitive insights from your research surprised you?"
        ✅ "Which aspects of your approach might competitors find hardest to replicate?"

        Now, generate **\(setQuestionNumber())** unique expert-level questions and answers based on this pitch:

        \(script)
        """
        
        Task {
            do {
                let result = try await model.generateContent(prompt)
                if let responseText = result.text {
                    print("API Response: \(responseText)")
                    
                    // Create a new session ID when generating questions
                    let sessionId = UUID()
                    
                    // Parse and create questions with IDs and session ID
                    let questionsAndAnswers = parseQuestionsAndAnswers(from: responseText, sessionId: sessionId)
                    print("Generated \(questionsAndAnswers.count) new questions from \(randomPerspective) perspective")
                    completion(questionsAndAnswers)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error generating content: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
