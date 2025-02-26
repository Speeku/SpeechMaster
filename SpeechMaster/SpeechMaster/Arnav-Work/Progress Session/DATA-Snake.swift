//
//  DATA-Snake.swift
//  SpeechMaster
//
//  Created by Kushagra Kulshrestha on 10/02/25.
//

import Foundation

class DataController: ObservableObject {
    // MARK: - Singleton
    static let shared = DataController()
    
    // MARK: - Published Properties

    @Published var sessionsArray: [PracticeSession] = []
    @Published var qnaArray: [QnASession] = []
    @Published var qnaQuestions: [QnAQuestion] = []
    
    // MARK: - Initialization
    private init() {
        // Private initializer to ensure singleton pattern
        // Load any saved data here if needed
    }

    // MARK: - Session Management
    func addQnASessions(_ qna: QnASession) {
        self.qnaArray.append(qna)
        print("Added QnA session: \(qna.title) with ID: \(qna.id) at \(qna.createdAt)")
        // Add persistence logic here if needed
    }
    
    func addSession(_ session: PracticeSession) {
        self.sessionsArray.append(session)
        // Add persistence logic here if needed
    }
    
    func getAllSessions() -> [PracticeSession] {
        return sessionsArray
    }
    
    func getSessions(for scriptId: UUID) -> [PracticeSession] {
        return sessionsArray.filter { $0.scriptId == scriptId }
            .sorted { $0.createdAt > $1.createdAt } // Sort by creation date, newest first
    }
    
    // MARK: - QnA Methods
    func addQnAQuestions(_ questions: [QnAQuestion]) {
        qnaQuestions.append(contentsOf: questions)
        print("Added \(questions.count) questions to storage")
        // Print first question's session ID as verification
        if let firstQuestion = questions.first {
            print("First question belongs to session: \(firstQuestion.qna_session_Id)")
        }
    }
    
    func getQuestions(for sessionId: UUID) -> [QnAQuestion] {
        return qnaQuestions.filter { $0.qna_session_Id == sessionId }
    }
    
    func getQnASessions(for scriptId: UUID) -> [QnASession] {
        let sessions = qnaArray.filter { $0.scriptId == scriptId }
        print("Found \(sessions.count) QnA sessions for script \(scriptId)")
        return sessions.sorted { $0.createdAt > $1.createdAt } // Sort newest first
    }
    
    // MARK: - Data Persistence (TODO)
    private func saveData() {
        // Implement data saving logic
    }
    
    private func loadData() {
        // Implement data loading logic
    }
}
