import Foundation

struct Script: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var date: Date
    var isPinned: Bool
    
    static func == (lhs: Script, rhs: Script) -> Bool {
        lhs.id == rhs.id
    }
}
