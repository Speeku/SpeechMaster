struct Progress{
    var name : String
    var fillerWords: Int
    var missingWords : Int
    var pace : Double
    var pronunciation : Double
    var overall : Double{
        return (Double(fillerWords + missingWords) + pace + pronunciation)/4.0
    }}
