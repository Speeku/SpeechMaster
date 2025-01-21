//
//  Data-PerformanceScreen.swift
//  SpeechMaster
//
//  Created by Piyush on 19/01/25.
//

import Foundation
import UIKit

var video: [Video] = []

var summary : [Summary] = [
    Summary(timeSpent: "3:19")
]

var fillers : [Fillers] = [
    Fillers(noOfFillersWords: "7")
]

var missingWords : [MissingWords] = [
    MissingWords(noOfMissingWords: "9")
]

var pace : [Pace] = [
    Pace( graphPlaceHolder: UIImage(named: "graph")!)
]

//var pronunciation = [
//    Pronunciation(missPronouncedWords: <#T##[UIButton]#>, practiceWord: <#T##String#>, howToPronunce: <#T##String#>)
//]

var pitch : [Pitch] = [
    Pitch(graphPlaceHolder: UIImage(named: "PitchGraph")!)
]

var originality : [Originality] = [
    Originality(originalityStatus: "You avoided reading slide text aloud. That's good for keeping the audience engaged with your message.")
]
