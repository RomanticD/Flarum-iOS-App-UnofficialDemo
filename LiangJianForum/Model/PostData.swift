// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let postData = try? JSONDecoder().decode(PostData.self, from: jsonData)

import Foundation

// MARK: - PostData
struct PostData: Codable, Hashable {
    let data: DataClass
    let included: [Included4]
}

// MARK: - DataClass
struct DataClass: Codable, Hashable {
    let type: String
    let id: String
    let attributes: DataAttributes4
    let relationships: DataRelationships4
}

// MARK: - DataAttributes
struct DataAttributes4: Codable, Hashable {
    let title, slug: String?
    let commentCount, participantCount: Int?
    let createdAt, lastPostedAt: String
    let lastPostNumber: Int?
    let canReply, canRename, canDelete, canHide: Bool?
    let isApproved, canTag: Bool?
    let subscription: JSONNull4?
    let isSticky, canSticky, isLocked, canLock: Bool?
}

// MARK: - DataRelationships
struct DataRelationships4: Codable, Hashable {
    let user: User4
    let posts: Posts4
}

// MARK: - Posts
struct Posts4: Codable, Hashable {
    let data: [DAT4]
}

// MARK: - DAT
struct DAT4: Codable, Hashable {
    let type: String
    let id: String
}

enum TypeEnum: String, Codable, Hashable {
    case discussions = "discussions"
    case groups = "groups"
    case posts = "posts"
    case users = "users"
}

// MARK: - User
struct User4: Codable, Hashable {
    let data: DAT4
}

// MARK: - Included
struct Included4: Codable, Hashable {
    let type: String
    let id: String
    let attributes: IncludedAttributes4
    let relationships: IncludedRelationships4?
}

// MARK: - IncludedAttributes
struct IncludedAttributes4: Codable, Hashable {
    let username, displayName: String?
    let avatarURL: String?
    let slug: String?
    let joinTime: String?
    let discussionCount, commentCount: Int?
    let canEdit, canEditCredentials, canEditGroups, canDelete: Bool?
    let lastSeenAt: String?
    let canSuspend, canEditNickname: Bool?
    let number: Int?
    let createdAt: String?
    let contentType: String?
    let contentHTML: String?
    let renderFailed, canHide, canFlag, canLike: Bool?
    let isApproved, canApprove: Bool?
    let editedAt: String?
    let nameSingular, namePlural, color, icon: String?
    let isHidden: Int?

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, canEdit, canEditCredentials, canEditGroups, canDelete, lastSeenAt, canSuspend, canEditNickname, number, createdAt, contentType
        case contentHTML = "contentHtml"
        case renderFailed, canHide, canFlag, canLike, isApproved, canApprove, editedAt, nameSingular, namePlural, color, icon, isHidden
    }
}

enum ContentType: String, Codable {
    case comment = "comment"
    case discussionRenamed = "discussionRenamed"
}

// MARK: - IncludedRelationships
struct IncludedRelationships4: Codable, Hashable {
    let groups: Posts4?
    let discussion, user: User4?
    let mentionedBy, likes: Posts4?
    let editedUser: User4?
}

// MARK: - Encode/decode helpers

class JSONNull4: Codable, Hashable {

    public static func == (lhs: JSONNull4, rhs: JSONNull4) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull4.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

