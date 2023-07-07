// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let tags = try? JSONDecoder().decode(Tags.self, from: jsonData)

import Foundation

// MARK: - Tags
struct TagsData: Codable, Hashable {
    let data: [Datum6]
//    let included: [Included6]
}

// MARK: - Datum
struct Datum6: Codable, Hashable {
    let type: String
    let id: String
    let attributes: Attributes6
//    let relationships: Relationships6?
}

// MARK: - Attributes
struct Attributes6: Codable, Hashable {
    let name, description, slug, color: String
    let icon: String?
    let discussionCount, position: Int?
    let isChild, isHidden: Bool
    let lastPostedAt: String?
    let canStartDiscussion, canAddToDiscussion: Bool

    enum CodingKeys: String, CodingKey {
        case name, description, slug, color
        case icon, discussionCount, position, isChild, isHidden, lastPostedAt, canStartDiscussion, canAddToDiscussion
    }
}

//// MARK: - Relationships
//struct Relationships6: Codable {
//    let parent: Parent6
//}
//
//// MARK: - Parent
//struct Parent6: Codable {
//    let data: DataClass6
//}

// MARK: - DataClass
struct DataClass6: Codable, Hashable {
    let type: String
    let id: String
}

// MARK: - Included
//struct Included6: Codable {
//    let type: String
//    let id: String
//    let attributes: Attributes6
//}
