//
//  HeaderSlideData.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/25.
//

import Foundation

// MARK: - HeaderSlideData
struct HeaderSlideData: Codable, Hashable {
    let transitionTime: String
    let list: [SlideData]
}

// MARK: - List
struct SlideData: Codable, Hashable {
    let image: String
    let link: String
}

