import Foundation

// MARK: - Top Speech Models

/// Represents a featured speech from a notable speaker
struct TopSpeech: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String
    let category: SpeechCategory
    let year: Int
    let duration: TimeInterval
    let tags: [String]
    let isFeatured: Bool
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String, 
         imageName: String,
         category: SpeechCategory = .other,
         year: Int,
         duration: TimeInterval = 0,
         tags: [String] = [],
         isFeatured: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.category = category
        self.year = year
        self.duration = duration
        self.tags = tags
        self.isFeatured = isFeatured
    }
}

/// Categories for different types of speeches
enum SpeechCategory: String, Codable {
    case technology = "Technology"
    case leadership = "Leadership"
    case education = "Education"
    case motivation = "Motivation"
    case sports = "Sports"
    case politics = "Politics"
    case literature = "Literature"
    case other = "Other"
}

/// Detailed information about a speech video
struct VideoDetails: Identifiable, Codable {
    let id: UUID
    let title: String
    let videoURL: String
    let summary: [TimeStampSection]
    let transcript: String?
    let viewCount: Int
    let rating: Double
    let lastUpdated: Date
    
    init(id: UUID = UUID(),
         title: String,
         videoURL: String,
         summary: [TimeStampSection],
         transcript: String? = nil,
         viewCount: Int = 0,
         rating: Double = 0.0,
         lastUpdated: Date = Date()) {
        self.id = id
        self.title = title
        self.videoURL = videoURL
        self.summary = summary
        self.transcript = transcript
        self.viewCount = viewCount
        self.rating = rating
        self.lastUpdated = lastUpdated
    }
}

/// Represents a section of the speech with timestamp and analysis
struct TimeStampSection: Identifiable, Codable {
    let id: UUID
    let title: String
    let timeRange: String
    let details: SectionDetails
    let startTime: TimeInterval
    let endTime: TimeInterval
    
    init(id: UUID = UUID(),
         title: String,
         timeRange: String,
         details: SectionDetails,
         startTime: TimeInterval = 0,
         endTime: TimeInterval = 0) {
        self.id = id
        self.title = title
        self.timeRange = timeRange
        self.details = details
        self.startTime = startTime
        self.endTime = endTime
    }
}

/// Detailed analysis of a speech section
struct SectionDetails: Codable {
    let bodyLanguage: String
    let adaptationTip: String
    let speech: String?
    let confidence: Double
    let keywords: [String]
    
    init(bodyLanguage: String,
         adaptationTip: String,
         speech: String? = nil,
         confidence: Double = 1.0,
         keywords: [String] = []) {
        self.bodyLanguage = bodyLanguage
        self.adaptationTip = adaptationTip
        self.speech = speech
        self.confidence = confidence
        self.keywords = keywords
    }
} 
