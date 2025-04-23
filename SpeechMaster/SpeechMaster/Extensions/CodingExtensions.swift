import Foundation

// MARK: - Coding Keys Extensions
extension User {
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
        case lastLoginAt = "last_login_date" 
        case preferences
    }
    
    // Custom decoder to handle the Supabase response format
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID coming as string from Supabase
        if let uuidString = try? container.decode(String.self, forKey: .id) {
            id = UUID(uuidString: uuidString) ?? UUID()
        } else {
            id = try container.decode(UUID.self, forKey: .id)
        }
        
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        
        // Handle different date formats
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                createdAt = Date()
            }
        } else if let timestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            createdAt = Date()
        }
        
        // Handle different date formats for last login
        if let dateString = try? container.decode(String.self, forKey: .lastLoginAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                lastLoginAt = date
            } else {
                lastLoginAt = Date()
            }
        } else if let timestamp = try? container.decode(Double.self, forKey: .lastLoginAt) {
            lastLoginAt = Date(timeIntervalSince1970: timestamp)
        } else {
            lastLoginAt = Date()
        }
        
        // Handle preferences as JSON object
        if let preferencesData = try? container.decode(Data.self, forKey: .preferences) {
            let decoder = JSONDecoder()
            preferences = try decoder.decode(UserPreferences.self, from: preferencesData)
        } else if let preferencesDict = try? container.decode([String: Any].self, forKey: .preferences) as? [String: Bool] {
            preferences = UserPreferences(
                isDarkMode: preferencesDict["isDarkMode"] ?? false,
                notificationsEnabled: preferencesDict["notificationsEnabled"] ?? true,
                emailNotificationsEnabled: preferencesDict["emailNotificationsEnabled"] ?? true
            )
        } else {
            // Default preferences if none are found
            preferences = UserPreferences(
                isDarkMode: false,
                notificationsEnabled: true,
                emailNotificationsEnabled: true
            )
        }
    }
}

// MARK: - JSON Decoding Extensions
extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type, forKey key: Key) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: [String: Any].Type, forKey key: Key) throws -> [String: Any]? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: [Any].Type, forKey key: Key) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: [Any].Type, forKey key: Key) throws -> [Any]? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            } else if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = NSNull()
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self) {
                array.append(nestedArray)
            } else if try decodeNil() {
                array.append(NSNull())
            }
        }
        return array
    }
    
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try container.decode(type)
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
} 