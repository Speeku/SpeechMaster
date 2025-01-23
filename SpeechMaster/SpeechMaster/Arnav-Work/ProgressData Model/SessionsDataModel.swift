//
//  DataModel.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import Foundation
struct Session{
    var name :String
}
struct Sessions{
    var name : String
    var date : String
}
struct QnA{
    var name  : String
    var date : String
}
struct Progress{
    var name : String
    var fillerWords: Int
    var missingWords : Int
    var pace : Double
    var pronunciation : Double
    var overall : Double{
        return (Double(fillerWords + missingWords) + pace + pronunciation)/4.0
    }


}
