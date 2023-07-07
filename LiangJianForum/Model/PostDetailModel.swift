import Foundation

// MARK: - PostDetail
struct PostDetail: Codable {
    let data: PostDetailData
    let included: [Included3]
}

// MARK: - PostDetailData
struct PostDetailData: Codable {
    let type, id: String
    let attributes: DataAttributes
    let relationships: Relationships
}

// MARK: - DataAttributes
struct DataAttributes: Codable {
    let number: Int
    let createdAt: String
    let contentType: String
    let contentHTML: String

    enum CodingKeys: String, CodingKey {
        case number, createdAt, contentType
        case contentHTML = "contentHtml"
    }
}

// MARK: - Relationships
struct Relationships: Codable {
    let user, discussion: Discussion3
}

// MARK: - Discussion
struct Discussion3: Codable {
    let data: DiscussionData
}

// MARK: - DiscussionData
struct DiscussionData: Codable {
    let type, id: String
}

// MARK: - Included
struct Included3: Codable {
    let type, id: String
    let attributes: IncludedAttributes3
}

// MARK: - IncludedAttributes
struct IncludedAttributes3: Codable {
    let username, displayName: String?
    let avatarURL: String?
    let slug: String?
    let joinTime: String?
    let discussionCount, commentCount: Int?
    let nameSingular, namePlural, color, icon: String?
    let isHidden: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case username, displayName
        case avatarURL = "avatarUrl"
        case slug, joinTime, discussionCount, commentCount, nameSingular, namePlural, color, icon, isHidden, title
    }
}
