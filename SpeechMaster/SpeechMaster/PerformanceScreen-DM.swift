import Foundation
import UIKit

//struct RehearsalReport: Codable, Identifiable {
//    let id: UUID  // Unique identifier for the report
//    let videoURL: URL
//    let summary: String
//    
//    // Fillers
//    let fillerCount: Int
//    let fillerDetails: [String: Int]
//    
//    // Missing Words
//    let missingWordCount: Int
//    let missingWords: [String]
//    
//    // Pace
//    let pace: Int
//    let paceGraph: [GraphPoint]
//    
//    // Pronunciation
//    let mispronouncedWords: [String]
//    
//    // Pitch
//    let pitchGraph: [GraphPoint]  // Graph points for pitch
//    
//    // Originality
//    let originality: String
//}
//
//// Supporting struct for graph data points
//struct GraphPoint: Codable {
//    let timestamp: TimeInterval  // Time since the start of the session
//    let value: Float  // Value at the given timestamp
//}


struct Video {
    var showImage : UIImage
}

struct Summary {
    var timeSpent : String
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

