//
//  TagData.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/27.
//

import SwiftUI

class TagData: ObservableObject {
    @Published var tags: [TagInfo] = [
        TagInfo(imageName: "lightbulb.max.fill", content: "官方公示", color: Color(hex: "FF0000")),
        TagInfo(imageName: "scanner.fill", content: "闲置物品", color: Color(hex: "FF7F00")),
        TagInfo(imageName: "star.fill", content: "疑问解答", color: Color(hex: "FFC200")),
        TagInfo(imageName: "message.fill", content: "失物招领", color: Color(hex: "00FF7F")),
        TagInfo(imageName: "person.fill", content: "我要吐槽", color: Color(hex: "0000FF")),
        TagInfo(imageName: "moon.circle.fill", content: "温馨提示", color: Color(hex: "4B0082")),
        TagInfo(imageName: "location.fill.viewfinder", content: "大海捞人", color: Color(hex: "8F00FF")),
        TagInfo(imageName: "music.quarternote.3", content: "分享生活", color: Color(hex: "FF00FF")),
        TagInfo(imageName: "heart.fill", content: "脱单告急", color: Color(hex: "FF1493")),
        TagInfo(imageName: "lasso.badge.sparkles", content: "拼单专区", color: Color(hex: "00FFFF")),
        TagInfo(imageName: "circlebadge.2.fill", content: "广告宣传", color: Color(hex: "FFD700"))
    ]
}
