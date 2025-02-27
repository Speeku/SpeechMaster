import Foundation

enum KeynoteError: Error {
    case bookmarkDataNotFound
    case urlAccessError
    case invalidURL
    case fileNotFound
    
    var localizedDescription: String {
        switch self {
        case .bookmarkDataNotFound:
            return "Keynote bookmark data not found"
        case .urlAccessError:
            return "Cannot access keynote file"
        case .invalidURL:
            return "Invalid keynote file URL"
        case .fileNotFound:
            return "Keynote file not found"
        }
    }
}

class KeynoteManager {
    static let shared = KeynoteManager()
    
    private let userDefaults = UserDefaults.standard
    private let bookmarkKey = "keynote_bookmark"
    private var secureURL: URL?
    
    private init() {}
    
    func saveKeynoteURL(_ url: URL, bookmarkData: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            completion(.failure(KeynoteError.urlAccessError))
            return
        }
        
        // Store both the original URL and the bookmark data
        secureURL = url
        userDefaults.set(bookmarkData, forKey: bookmarkKey)
        completion(.success(()))
    }
    
    func loadKeynote(completion: @escaping (Result<URL, Error>) -> Void) {
        // First try using the secure URL if available
        if let url = secureURL {
            guard FileManager.default.fileExists(atPath: url.path) else {
                completion(.failure(KeynoteError.fileNotFound))
                return
            }
            
            // Ensure we can access the file
            guard url.startAccessingSecurityScopedResource() else {
                completion(.failure(KeynoteError.urlAccessError))
                return
            }
            
            completion(.success(url))
            return
        }
        
        // Fallback to bookmark data
        guard let bookmarkData = userDefaults.data(forKey: bookmarkKey) else {
            completion(.failure(KeynoteError.bookmarkDataNotFound))
            return
        }
        
        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            // Ensure we can access the file
            guard url.startAccessingSecurityScopedResource() else {
                completion(.failure(KeynoteError.urlAccessError))
                return
            }
            
            if isStale {
                let newBookmarkData = try url.bookmarkData(
                    options: .minimalBookmark,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                userDefaults.set(newBookmarkData, forKey: bookmarkKey)
            }
            
            guard FileManager.default.fileExists(atPath: url.path) else {
                url.stopAccessingSecurityScopedResource()
                completion(.failure(KeynoteError.fileNotFound))
                return
            }
            
            secureURL = url
            completion(.success(url))
        } catch {
            completion(.failure(error))
        }
    }
    
    func clearKeynote() {
        if let url = secureURL {
            url.stopAccessingSecurityScopedResource()
        }
        secureURL = nil
        userDefaults.removeObject(forKey: bookmarkKey)
    }
} 
