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


struct Script: Identifiable,Codable,Equatable {
    let id: UUID
    let userId: UUID
    let title: String
    let scriptText: String
    //var progress: Double = 0
    let createdAt: Date
    var isKeynoteAssociated: Bool
    var keynoteURL: String?
    var isPinned: Bool
    static func == (lhs: Script, rhs: Script) -> Bool {
            lhs.id == rhs.id
        }
}

struct PracticeSession: Identifiable, Codable {
    let id: UUID
    let scriptId: UUID
    let recordingURL: String
    let createdAt: Date
    let title: String
    let hasKeynote: Bool
    let reportId: UUID
}
struct QnASession: Identifiable, Codable {
    let id: UUID
    let scriptId: UUID
    let createdAt: Date
    let title: String
}
struct QnAReport: Identifiable, Codable {
    let id: UUID
    let QnASessionId: UUID
    let questionText: String
    let userAnswer: String
    let suggestedAnswer: String
    let timeTaken: TimeInterval
}

// MARK: - Analysis Entities


struct Report: Identifiable{
    let id: UUID
   // let sessionId: UUID
    let missingWords: MissingWords
    let fillerWords: Fillers
    var pace: Double // Words per minute
    let pitch: Pitch
    let originality: Originality
    let pronunciationScore: Double
}

struct QnAQuestion: Identifiable, Codable {
    let id: UUID
    let questionText: String
}

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
struct Video {
    var showImage : UIImage
    var videoURL: URL?
}

struct Summary {
    var timeSpent: String
}

struct Fillers {
    var noOfFillersWords : String
}

struct MissingWords {
    var noOfMissingWords : String
}

struct Pace {
    //var wordsPerMin : String
    var graphPlaceHolder : UIImage
}

struct Pronunciation {
    var missPronouncedWords : [UIButton]
    var practiceWord : String
    var howToPronunce : String
}

struct Pitch {
    var graphPlaceHolder : UIImage
}

struct Originality {
    var originalityStatus : String
}
