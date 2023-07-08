// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let notificationData = try? JSONDecoder().decode(NotificationData.self, from: jsonData)

import Foundation

// MARK: - NotificationData
struct NotificationData: Codable {
    let links: Links7
    let data: [Datum7]
    let included: [Included7]?
}

// MARK: - Datum
struct Datum7: Codable {
    let type, id: String?
    let attributes: DatumAttributes7?
    let relationships: DatumRelationships7?
}

// MARK: - DatumAttributes
struct DatumAttributes7: Codable {
    let contentType: String
    let content: Content
    let createdAt: String
    let isRead: Bool
}

// MARK: - Content
struct Content: Codable {
    let replyNumber: Int?
}

// MARK: - DatumRelationships
struct DatumRelationships7: Codable {
    let fromUser, subject: FromUser?
}

// MARK: - FromUser
struct FromUser: Codable {
    let data: DataClass7?
}

// MARK: - DataClass
struct DataClass7: Codable {
    let type: String
    let id: String
}

// MARK: - Included
struct Included7: Codable {
    let type: String
    let id: String
    let attributes: IncludedAttributes7
    let relationships: IncludedRelationships7?
}

// MARK: - IncludedAttributes
struct IncludedAttributes7: Codable {
    let username, displayName: String?
    let avatarURL: String?
    let slug: String?
    let number: Int?
    let createdAt: String?
    let contentType, contentHTML: String?
    let renderFailed: Bool?
    let content: String?
    let editedAt: String?
    let canEdit, canDelete, canHide: Bool?
    let mentionedByCount: Int?
    let canFlag, isApproved, canApprove: Bool?
    let votes: JSONNull7?
    let canVote, seeVoters, canLike: Bool?
    let likesCount: Int?
    let title: String?
    let hasUpvoted, hasDownvoted, seeVotes, hasBestAnswer: Bool?
    let bestAnswerSetAt: JSONNull7?

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, number, createdAt, contentType
        case contentHTML = "contentHtml"
        case renderFailed, content, editedAt, canEdit, canDelete, canHide, mentionedByCount, canFlag, isApproved, canApprove, votes, canVote, seeVoters, canLike, likesCount, title, hasUpvoted, hasDownvoted, seeVotes, hasBestAnswer, bestAnswerSetAt
    }
}

// MARK: - IncludedRelationships
struct IncludedRelationships7: Codable {
    let discussion: FromUser?
}

// MARK: - Links
struct Links7: Codable {
    let first: String
    let next:String?
    let prev: String?
}

// MARK: - Encode/decode helpers

class JSONNull7: Codable, Hashable {

    public static func == (lhs: JSONNull7, rhs: JSONNull7) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull7.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

