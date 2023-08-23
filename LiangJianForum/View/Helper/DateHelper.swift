//
//  DateHelper.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/27.
//

import Foundation

public func calculateTimeDifference(from dateString: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from: dateString) else {
        return NSLocalizedString("无效的日期格式", comment: "")
    }
    
    let currentTime = Date()
    let calendar = Calendar.current
    
    let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: currentTime)
    
    if let day = components.day, day > 0 {
        return String.localizedStringWithFormat(NSLocalizedString("days ago", comment: ""), day)
    } else if let hour = components.hour, hour > 0 {
        return String.localizedStringWithFormat(NSLocalizedString("hours ago", comment: ""), hour)
    } else if let minute = components.minute, minute > 0 {
        return String.localizedStringWithFormat(NSLocalizedString("minutes ago", comment: ""), minute)
    } else {
        return NSLocalizedString("just now", comment: "")
    }
}


public func removeFirstCharacter(from colorString: String) -> String {
    let index = colorString.index(after: colorString.startIndex)
    return String(colorString[index...])
}
