// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let userComment = try? JSONDecoder().decode(UserComment.self, from: jsonData)

import Foundation

// MARK: - UserComment
struct UserCommentData: Codable, Hashable {
    let links: Links8
    let data: [Datum8]
    let included: [Included8]
}

// MARK: - Datum
struct Datum8: Codable, Hashable {
    let type: String
    let id: String
    let attributes: DatumAttributes8
    let relationships: DatumRelationships8
//    let commentCount : Int?
}

// MARK: - DatumAttributes
struct DatumAttributes8: Codable, Hashable {
    let number: Int
    let createdAt: String
    let contentType: String
    let contentHTML: String?
//    let renderFailed: Bool?
//    let canEdit, canDelete, canHide: Bool
    let mentionedByCount: Int?
//    let canFlag, isApproved, canApprove: Bool
//    let canVote, seeVoters, canLike: Bool?
    let likesCount: Int?
    let editedAt: String?

    enum CodingKeys: String, CodingKey {
        case number, createdAt, contentType
        case contentHTML = "contentHtml"
        case mentionedByCount, likesCount, editedAt
    }
}

// MARK: - DatumRelationships
struct DatumRelationships8: Codable, Hashable {
    let user, discussion: Discussion8
//    let eventPostMentionsTags, mentionedBy, likes, warnings: EventPostMentionsTags8?
//    let editedUser: Discussion8?
}

// MARK: - Discussion
struct Discussion8: Codable , Hashable{
    let data: DAT8
}

// MARK: - DAT
struct DAT8: Codable, Hashable {
    let type: String
    let id: String
}

// MARK: - EventPostMentionsTags
struct EventPostMentionsTags8: Codable, Hashable {
    let data: [DAT8]
}

// MARK: - Included
struct Included8: Codable, Hashable {
    let type: String
    let id: String
    let attributes: IncludedAttributes8
//    let relationships: IncludedRelationships8?
}

// MARK: - IncludedAttributes
struct IncludedAttributes8: Codable, Hashable {
    let username, displayName: String?
    let avatarURL: String?
    let slug: String?
    let joinTime: String?
    let discussionCount, commentCount: Int?
//    let canEdit, canEditCredentials, canEditGroups, canDelete: Bool?
    let lastSeenAt: String?
    let isEmailConfirmed: Bool?
    let email: String?
//    let suspendMessage, suspendedUntil: JSONNull8?
//    let canSuspend: Bool?
//    let usernameHistory: JSONNull8?
    let bio: String?
//    let canViewBio, canEditBio, canSpamblock, blocksPD: Bool?
//    let cannotBeDirectMessaged: Bool?
//    let points: Int?
//    let canHaveVotingNotifications, ignored, canBeIgnored: Bool?
//    let bestAnswerCount: Int?
//    let canViewWarnings, canManageWarnings, canDeleteWarnings: Bool?
//    let visibleWarningCount: Int?
    let title: String?
//    let isApproved, hasUpvoted, hasDownvoted, seeVotes: Bool?
//    let hasBestAnswer: HasBestAnswer
//    let bestAnswerSetAt: JSONNull8?
    let number: Int?
    let createdAt: String?
//    let contentType, contentHTML: String?
//    let renderFailed: Bool?
    let mentionedByCount: Int?

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, lastSeenAt, isEmailConfirmed, email, bio
        case title, number, createdAt
        case mentionedByCount
    }
}

// MARK: - IncludedRelationships
struct IncludedRelationships8: Codable, Hashable {
    let groups, ranks: EventPostMentionsTags8?
    let user, discussion: Discussion8?
}

// MARK: - Links
struct Links8: Codable, Hashable {
    let first: String
    let prev: String?
    let next: String?
}
