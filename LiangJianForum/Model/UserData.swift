// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let userData = try? JSONDecoder().decode(UserData.self, from: jsonData)

import Foundation

// MARK: - UserData
struct UserData: Codable {
    let data: DataClass2
    let included: [UserInclude]?
}

// MARK: - DataClass
struct DataClass2: Codable {
    let type, id: String
    let attributes: Attributes2
}

// MARK: - Attributes
struct Attributes2: Codable {
    let username, displayName: String
    let avatarURL: String?
    let slug: String
    let joinTime: String
    let discussionCount, commentCount: Int
    let lastSeenAt: String?
    let isAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, lastSeenAt, isAdmin
    }
}

// MARK: - UserInclude
struct UserInclude: Codable {
    let type, id: String
    let attributes: Attributes
}

// MARK: - Attributes
struct Attributes: Codable {
    let nameSingular, namePlural, color, icon: String
    let isHidden: Int
}

