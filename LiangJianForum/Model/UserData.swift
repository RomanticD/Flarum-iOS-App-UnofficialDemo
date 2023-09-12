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
    let lastSeenAt, cover, bioHtml: String?
    let isAdmin: Bool?
    let money: Double?
    let canCheckin, canCheckinContinuous: Bool?
    let totalContinuousCheckIn: Int?
    

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, lastSeenAt, cover, bioHtml, isAdmin, money, canCheckin, canCheckinContinuous, totalContinuousCheckIn
    }
}

// MARK: - UserInclude
struct UserInclude: Codable, Hashable {
    let type, id: String
    let attributes: Attributes
}

// MARK: - Attributes
struct Attributes: Codable, Hashable {
    let nameSingular, namePlural, color, icon: String?
    let isHidden: Int?
    let name: String?
    let description: String?
    let backgroundColor: String?
}

