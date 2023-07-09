//
// Created by Romantic D on 2023/7/9.
//

import Foundation

struct DiscussionDataWithId: Codable{
    let data: Datum9
}

struct Datum9: Codable {
    let type: String
    let id: String
    let attributes: DataAttributes9
}

struct DataAttributes9: Codable {
    let commentCount : Int
}