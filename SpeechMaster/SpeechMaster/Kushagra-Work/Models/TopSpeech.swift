import Foundation
struct TopSpeech: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
} 
struct VideoDetails: Identifiable {
    let id = UUID()
    let title: String
    let videoURL: String
    let summary: [TimeStampSection]
}

struct TimeStampSection: Identifiable {
    let id = UUID()
    let title: String
    let timeRange: String
    let details: SectionDetails
}

struct SectionDetails {
    let bodyLanguage: String
    let adaptationTip: String
    let speech: String?
} 
