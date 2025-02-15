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
    
    // MARK: - Initialization
    private init() {
        // Private initializer to ensure singleton pattern
        // Load any saved data here if needed
    }

    // MARK: - Session Management
    func addQnASessions(_ qna: QnASession) {
        self.qnaArray.append(qna)
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
    
    // MARK: - Data Persistence (TODO)
    private func saveData() {
        // Implement data saving logic
    }
    
    private func loadData() {
        // Implement data loading logic
    }
}
