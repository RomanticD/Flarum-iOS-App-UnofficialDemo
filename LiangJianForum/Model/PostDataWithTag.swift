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
struct DataAttributes5: Codable, Hashable {
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
    let hasBestAnswer: Int?

    enum CodingKeys: String, CodingKey {
        case title, slug, commentCount, participantCount, createdAt, lastPostedAt, lastPostNumber, canReply, canRename, canDelete, canHide, lastReadAt, lastReadPostNumber, isApproved, canTag, subscription, isSticky, canSticky, isLocked, canLock, hasBestAnswer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let intVal = try? container.decode(Int.self, forKey: .hasBestAnswer) {
            self.hasBestAnswer = intVal
        } else if let boolVal = try? container.decode(Bool.self, forKey: .hasBestAnswer) {
            self.hasBestAnswer = boolVal ? -1 : 0
        } else {
            self.hasBestAnswer = nil
        }
        
        // Decode other properties
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount)
        participantCount = try container.decodeIfPresent(Int.self, forKey: .participantCount)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        lastPostedAt = try container.decodeIfPresent(String.self, forKey: .lastPostedAt)
        lastPostNumber = try container.decodeIfPresent(Int.self, forKey: .lastPostNumber)
        canReply = try container.decodeIfPresent(Bool.self, forKey: .canReply)
        canRename = try container.decodeIfPresent(Bool.self, forKey: .canRename)
        canDelete = try container.decodeIfPresent(Bool.self, forKey: .canDelete)
        canHide = try container.decodeIfPresent(Bool.self, forKey: .canHide)
        lastReadAt = try container.decodeIfPresent(String.self, forKey: .lastReadAt)
        lastReadPostNumber = try container.decodeIfPresent(Int.self, forKey: .lastReadPostNumber)
        isApproved = try container.decodeIfPresent(Bool.self, forKey: .isApproved)
        canTag = try container.decodeIfPresent(Bool.self, forKey: .canTag)
        subscription = try container.decodeIfPresent(JSONNull5.self, forKey: .subscription)
        isSticky = try container.decodeIfPresent(Bool.self, forKey: .isSticky)
        canSticky = try container.decodeIfPresent(Bool.self, forKey: .canSticky)
        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked)
        canLock = try container.decodeIfPresent(Bool.self, forKey: .canLock)
    }
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
    let question, endDate, createdAT, answer: String?
    let voteCount, maxVotes: Int?
    let canVote, allowMultipleVotes, allowChangeVote, canChangeVote: Bool?
    let username, displayName: String?
    let avatarURL: String?
    let slug: String?
    let joinTime: String?
    let discussionCount, commentCount: Int?
    let mentionedByCount, likesCount: Int?
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
        case username, displayName, question, endDate, answer, createdAT, voteCount, canVote, allowMultipleVotes, maxVotes, allowChangeVote, canChangeVote
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, canEdit, canEditCredentials, canEditGroups, canDelete, lastSeenAt, canSuspend, canEditNickname, isEmailConfirmed, email, number, createdAt, contentType, editedAt
        case contentHTML = "contentHtml"
        case renderFailed, canHide, canFlag, canLike, isApproved, canApprove, nameSingular, namePlural, color, icon, name, description, mentionedByCount, likesCount
        case backgroundURL = "backgroundUrl"
        case backgroundMode, position, defaultSort, isChild, lastPostedAt, canStartDiscussion, canAddToDiscussion
    }
}


// MARK: - IncludedRelationships
struct IncludedRelationships5: Codable,Hashable {
    let groups: Posts5?
    let discussion, user: User5?
    let mentionedBy, likes: Posts5?
    let options, myVotes : Votes?
}

// MARK: - Votes
struct Votes: Codable, Hashable {
    let data: [DAT5]
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

