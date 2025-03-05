import Foundation
import UIKit
// MARK: - Core Entities
// MARK: - Authentication Models
struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var profileImageURL: String?
    var createdAt: Date
    var lastLoginAt: Date
    var preferences: UserPreferences
    
    struct UserPreferences: Codable {
        var isDarkMode: Bool
        var notificationsEnabled: Bool
        var emailNotificationsEnabled: Bool
    }
}

enum AuthError: Error {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userNotFound
    case invalidEmail
    case socialAuthCancelled
    case unknown(String)
}

//MARK: - Script Model
struct Script: Identifiable,Codable,Equatable {
    let id: UUID
    //let userId: UUID
    let title: String
    var scriptText: String
    //var progress: Double = 0
    let createdAt: Date
    //var isKeynoteAssociated: Bool
    //var keynoteURL: String?
    var isPinned: Bool
    static func == (lhs: Script, rhs: Script) -> Bool {
            lhs.id == rhs.id
        }
}

//MARK: - Practice Session Model
struct PracticeSession: Identifiable, Codable {
    let id: UUID
    let scriptId: UUID
    //let userId: UUID
    let createdAt: Date
    let title: String
}
struct QnASession: Identifiable, Codable {
    let id: UUID
    let scriptId: UUID
    let createdAt: Date
    let title: String
}
//struct QnAReport: Identifiable, Codable {
//    let id: UUID
//    let QnASessionId: UUID
//    let questionText: String
//    let userAnswer: String
//    let suggestedAnswer: String
//    let timeTaken: TimeInterval
//}

// MARK: - Analysis Entities


//struct Report: Identifiable{
//    let id: UUID
//    let sessionId: UUID
//    let missingWords: MissingWords
//    let fillerWords: Fillers
//    var pace: Double // Words per minute
//    let pitch: Pitch
//    let originality: Originality
//    let pronunciationScore: Double
//}

struct QnAQuestion: Identifiable, Codable {
    let id: UUID
    let qna_session_Id : UUID
    let questionText: String
    let userAnswer: String
    let suggestedAnswer: String
    let timeTaken : TimeInterval
}

//MARK: - Performance Report
struct PerformanceReport: Codable {
    let sessionID: UUID
    let wordsPerMinute: Int
    let fillerWords: [SpeechAnalysisResult.FillerWord]
    let missingWords: [SpeechAnalysisResult.MissingWord]
    let pronunciationErrors: [SpeechAnalysisResult.PronunciationError]
    let duration: TimeInterval
    let videoURL: URL?
    
    init(sessionID: UUID, 
         wordsPerMinute: Int,
         fillerWords: [SpeechAnalysisResult.FillerWord],
         missingWords: [SpeechAnalysisResult.MissingWord],
         pronunciationErrors: [SpeechAnalysisResult.PronunciationError],
         duration: TimeInterval,
         videoURL: URL?) {
        self.sessionID = sessionID
        self.wordsPerMinute = wordsPerMinute
        self.fillerWords = fillerWords
        self.missingWords = missingWords
        self.pronunciationErrors = pronunciationErrors
        self.duration = duration
        self.videoURL = videoURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionID, wordsPerMinute, fillerWords, missingWords, pronunciationErrors, duration, videoURLString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionID = try container.decode(UUID.self, forKey: .sessionID)
        wordsPerMinute = try container.decode(Int.self, forKey: .wordsPerMinute)
        fillerWords = try container.decode([SpeechAnalysisResult.FillerWord].self, forKey: .fillerWords)
        missingWords = try container.decode([SpeechAnalysisResult.MissingWord].self, forKey: .missingWords)
        pronunciationErrors = try container.decode([SpeechAnalysisResult.PronunciationError].self, forKey: .pronunciationErrors)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        if let urlString = try container.decodeIfPresent(String.self, forKey: .videoURLString) {
            videoURL = URL(string: urlString)
        } else {
            videoURL = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(wordsPerMinute, forKey: .wordsPerMinute)
        try container.encode(fillerWords, forKey: .fillerWords)
        try container.encode(missingWords, forKey: .missingWords)
        try container.encode(pronunciationErrors, forKey: .pronunciationErrors)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(videoURL?.absoluteString, forKey: .videoURLString)
    }
}

//MARK: - Speech Analysis Result
struct SpeechAnalysisResult: Codable {
    struct FillerWord: Codable {
        let word: String
        let count: Int
        let timestamps: [TimeInterval]
    }
    
    struct MissingWord: Codable {
        let word: String
        let expectedIndex: Int
        let context: String
    }
    
    struct PronunciationError: Codable {
        let word: String
        let timestamp: TimeInterval
        let actualPronunciation: String
        let expectedPronunciation: String
    }
    
    let totalDuration: TimeInterval
    let expectedDuration: TimeInterval
    let fillerWords: [FillerWord]
    let missingWords: [MissingWord]
    let pronunciationErrors: [PronunciationError]
    let averageWordsPerMinute: Double
    let scriptWordCount: Int
    let spokenWordCount: Int
    
    var durationScore: Double {
        // Calculate score
        let difference = abs(totalDuration - expectedDuration)
        let percentageDiff = difference / expectedDuration
        return max(0, 100 * (1 - percentageDiff))
    }
    
    var fillerWordsScore: Double {
        // filler word frequency
        let totalFillerCount = fillerWords.reduce(0) { $0 + $1.count }
        let fillerRatio = Double(totalFillerCount) / Double(spokenWordCount)
        return max(0, 100 * (1 - (fillerRatio * 5)))
    }
    
    var missingWordsScore: Double {
        // Score based on percentage
        let missingCount = missingWords.count
        let missingRatio = Double(missingCount) / Double(scriptWordCount)
        return max(0, 100 * (1 - missingRatio))
    }
    
    var pronunciationScore: Double {
        // Score based on pronunciation accuracy
        let errorCount = pronunciationErrors.count
        let errorRatio = Double(errorCount) / Double(spokenWordCount)
        return max(0, 100 * (1 - (errorRatio * 2)))
    }
    
    var overallScore: Double {
        // Weighted average of all scores
        return (durationScore * 0.25 +
                fillerWordsScore * 0.25 +
                missingWordsScore * 0.25 +
                pronunciationScore * 0.25)
    }
}

struct Session {
    let id: UUID
    let title: String
    let scriptId: UUID
    let createdAt: Date
    let performanceReport: PerformanceReport?
    
    // Computed Properties
    var formattedDuration: String {
        guard let report = performanceReport else { return "00:00" }
        let minutes = Int(report.duration) / 60
        let seconds = Int(report.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var performanceMetrics: [String: Double] {
        guard let report = performanceReport else { return [:] }
        
        return [
            "Filler Words": Double(report.fillerWords.count),
            "Missing Words": Double(report.missingWords.count),
            "Words/Min": Double(report.wordsPerMinute),
            "Duration": report.duration
        ]
    }
    
    // Initialize from PracticeSession
    init(from practiceSession: PracticeSession, report: PerformanceReport?) {
        self.id = practiceSession.id
        self.title = practiceSession.title
        self.scriptId = practiceSession.scriptId
        self.createdAt = practiceSession.createdAt
        self.performanceReport = report
    }
}

// MARK: - Memorization Models
//struct MemorizationSession: Identifiable, Codable {
//    let id: UUID
//    let scriptId: UUID
//    let createdAt: Date
//    var lastUpdatedAt: Date
//    var progress: Double // 0.0 to 1.0 representing percentage memorized
//    var technique: MemorizationTechnique
//    var sections: [MemorizationSection]
//    
//    init(scriptId: UUID, technique: MemorizationTechnique) {
//        self.id = UUID()
//        self.scriptId = scriptId
//        self.createdAt = Date()
//        self.lastUpdatedAt = Date()
//        self.progress = 0.0
//        self.technique = technique
//        self.sections = []
//    }
//}
//
//enum MemorizationTechnique: String, Codable, CaseIterable {
//    case chunking = "Chunking"
//    case recordAndListen = "Record & Listen"
//    
//    var description: String {
//        switch self {
//        case .chunking:
//            return "Break your script into smaller, manageable sections and memorize each chunk separately."
//        case .recordAndListen:
//            return "Record yourself reading the script and listen to it repeatedly."
//        }
//    }
//}
//
//struct MemorizationSection: Identifiable, Codable {
//    let id: UUID
//    let startIndex: Int
//    let endIndex: Int
//    let text: String
//    var mastered: Bool
//    var lastPracticed: Date?
//    
//    init(startIndex: Int, endIndex: Int, text: String) {
//        self.id = UUID()
//        self.startIndex = startIndex
//        self.endIndex = endIndex
//        self.text = text
//        self.mastered = false
//        self.lastPracticed = nil
//    }
//}

////
////  DataModel.swift
////  SpeechMaster
////
////  Created by Arnav Chauhan on 04/02/25.
////
//
//import Foundation
//// user
//struct User{
//   let userID : UUID
//   let name : String
//   let email : String
//}
//struct Script1{
//    let scriptID : UUID
//    let userID : UUID
//    
//    //let sessionArray : [Session1]
//    //let qnaArray : [UUID]
//    let dateCreated : Date
//    let title : String
//}
//class Session1 {
//    let sessionId: UUID
//    let recordingURL: String
//    let dateCreated: Date
//    let title : String
//  
//    
//    init(sessionId: UUID, recordingURL: String, dateCreated: Date, title: String) {
//        self.sessionId = sessionId
//        self.recordingURL = recordingURL
//        self.dateCreated = dateCreated
//        self.title = title
//    }
//    }
//struct Question {
//    let questionId: UUID = UUID()
//    let questionText: String
//    var answerText : String = ""
//    var timeTaken : String = "00:00"
//}
//struct WordReport{
//    var count : Int
//    var incorrectWords : [String]
//    var description : String
//}
//struct PitchReport{
//    var description  : String
//    var pitchValue : [Double]
//}
//class Report{
//    let reportId: UUID
//    var fillerWords : WordReport
//    var missingWords : WordReport
//    var pace : Double
//    var pronunciation : WordReport
//    var origaniltyDescription : String
//    var pitch : PitchReport
//    //var overall : Double{
//        //return (Double(fillerWords + missingWords) + pace + pronunciation)/4.0}
//    
//    init(reportId: UUID, fillerWords: WordReport, missingWords: WordReport, pace: Double, pronunciation: WordReport, pitch: PitchReport) {
//        self.reportId = reportId
//        self.fillerWords = fillerWords
//        self.missingWords = missingWords
//        self.pace = pace
//        self.pronunciation = pronunciation
//        self.origaniltyDescription = "Database"
//        self.pitch = pitch
//    }
//    // description
//}
//
//struct Video {
//    var showImage : UIImage
//    var videoURL: URL?
//}
//
//struct Summary {
//    var timeSpent: String
//}
//
//struct Fillers {
//    var noOfFillersWords : String
//}
//
//struct MissingWords {
//    var noOfMissingWords : String
//}
//
//struct Pace {
//    //var wordsPerMin : String
//    var graphPlaceHolder : UIImage
//}
//
//struct Pronunciation {
//    var missPronouncedWords : [UIButton]
//    var practiceWord : String
//    var howToPronunce : String
//}
//
//struct Pitch {
//    var graphPlaceHolder : UIImage
//}
//
//struct Originality {
//    var originalityStatus : String
//}
