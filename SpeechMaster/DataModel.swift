//
//  DataModel.swift
//  SpeechMaster
//
//  Created by Arnav Chauhan on 04/02/25.
//

import Foundation
// user
struct User{
   let userID : UUID
   let name : String
   let email : String
}
struct Script1{
    let scriptID : UUID
    let sessionArray : [Session1]
    let qnaArray : [UUID]
    let dateCreated : Date
    let title : String
}
class Session1 {
    let sessionId: UUID
    let recordingURL: String
    let dateCreated: Date
    let titile : String
  
    
    init(sessionId: UUID, recordingURL: String, dateCreated: Date, titile: String) {
        self.sessionId = sessionId
        self.recordingURL = recordingURL
        self.dateCreated = dateCreated
        self.titile = titile
    }
    }



struct Question {
    let questionId: UUID
    let dateCreated: Date
    let questionText: String
    let answerText : String = ""
}
struct WordReport{
    var count : Int
    var incorrectWords : [String]
    var description : String
}
struct PitchReport{
    var description  : String
    var pitchValue : [Double]
}
class Report{
    let reportId: UUID
    var fillerWords : WordReport
    var missingWords : WordReport
    var pace : Double
    var pronunciation : WordReport
    var origaniltyDescription : String
    var pitch : PitchReport
    //var overall : Double{
        //return (Double(fillerWords + missingWords) + pace + pronunciation)/4.0}
    
    init(reportId: UUID, fillerWords: WordReport, missingWords: WordReport, pace: Double, pronunciation: WordReport, pitch: PitchReport) {
        self.reportId = reportId
        self.fillerWords = fillerWords
        self.missingWords = missingWords
        self.pace = pace
        self.pronunciation = pronunciation
        self.origaniltyDescription = "Database"
        self.pitch = pitch
    }
    // description
}
