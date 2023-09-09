// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let moneyData = try? JSONDecoder().decode(MoneyData.self, from: jsonData)

import Foundation

// MARK: - MoneyData
struct MoneyData: Codable, Hashable {
    let data: [Datum10]
}

// MARK: - Datum
struct Datum10: Codable, Hashable {
    let type: String
    let id: String
    let attributes: Attributes10
}

// MARK: - Attributes
struct Attributes10: Codable, Hashable {
    let id: Int
    let money: Double
    let userID: Int
    let createTime: String
    let targetID, actorID: Int
    let data, reason: String

    enum CodingKeys: String, CodingKey {
        case id, money
        case userID = "user_id"
        case createTime = "create_time "
        case targetID = "target_id"
        case actorID = "actor_id"
        case data, reason
    }
}

