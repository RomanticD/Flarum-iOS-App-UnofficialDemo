// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let postDataWithTag = try? JSONDecoder().decode(PostDataWithTag.self, from: jsonData)

import Foundation

// MARK: - PostDataWithTag
struct PostDataWithTag: Codable,Hashable {
    let data: DataClass5
    let included: [Included5]
}

// MARK: - DataClass
struct DataClass5: Codable,Hashable {
    let type: String
    let id: String
    let attributes: DataAttributes5
    let relationships: DataRelationships5
}

// MARK: - DataAttributesz
struct DataAttributes5: Codable,Hashable {
    let title, slug: String
    let commentCount, participantCount: Int?
    let createdAt, lastPostedAt: String?
    let lastPostNumber: Int?
    let canReply, canRename, canDelete, canHide: Bool?
    let lastReadAt: String?
    let lastReadPostNumber: Int?
    let isApproved, canTag: Bool?
    let subscription: JSONNull5?
    let isSticky, canSticky, isLocked, canLock: Bool?
}

// MARK: - DataRelationships
struct DataRelationships5: Codable,Hashable {
    let user: User5
    let posts, tags: Posts5?
}

// MARK: - Posts
struct Posts5: Codable,Hashable {
    let data: [DAT5]
}

// MARK: - DAT
struct DAT5: Codable,Hashable {
    let type: String
    let id: String
}

// MARK: - User
struct User5: Codable,Hashable {
    let data: DAT5
}

// MARK: - Included
struct Included5: Codable,Hashable {
    let type: String
    let id: String
    let attributes: IncludedAttributes5
    let relationships: IncludedRelationships5?
}

// MARK: - IncludedAttributes
struct IncludedAttributes5: Codable,Hashable {
    let username, displayName: String?
    let avatarURL: String?
    let slug: String?
    let joinTime: String?
    let discussionCount, commentCount: Int?
    let canEdit, canEditCredentials, canEditGroups, canDelete: Bool?
    let lastSeenAt: String?
    let canSuspend, canEditNickname, isEmailConfirmed: Bool?
    let email: String?
    let number: Int?
    let createdAt: String?
    let contentType: String?
    let contentHTML: String?
    let renderFailed, canHide, canFlag, canLike: Bool?
    let isApproved, canApprove: Bool?
    let nameSingular, namePlural, color, icon: String?
    let name, description: String?
    let backgroundURL, backgroundMode: JSONNull5?
    let position: Int?
    let defaultSort: JSONNull5?
    let isChild: Bool?
    let lastPostedAt: String?
    let editedAt: String?
    let canStartDiscussion, canAddToDiscussion: Bool?

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, canEdit, canEditCredentials, canEditGroups, canDelete, lastSeenAt, canSuspend, canEditNickname, isEmailConfirmed, email, number, createdAt, contentType, editedAt
        case contentHTML = "contentHtml"
        case renderFailed, canHide, canFlag, canLike, isApproved, canApprove, nameSingular, namePlural, color, icon, name, description
        case backgroundURL = "backgroundUrl"
        case backgroundMode, position, defaultSort, isChild, lastPostedAt, canStartDiscussion, canAddToDiscussion
    }
}


// MARK: - IncludedRelationships
struct IncludedRelationships5: Codable,Hashable {
    let groups: Posts5?
    let discussion, user: User5?
    let mentionedBy, likes: Posts5?
}

// MARK: - Encode/decode helpers

class JSONNull5: Codable, Hashable {

    public static func == (lhs: JSONNull5, rhs: JSONNull5) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull5.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

