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
        return "无效的日期格式"
    }
    
    let currentTime = Date()
    let calendar = Calendar.current
    
    let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: currentTime)
    
    if let day = components.day, day > 0 {
        return " \(day) days ago"
    } else if let hour = components.hour, hour > 0 {
        return " \(hour) hours ago"
    } else if let minute = components.minute, minute > 0 {
        return " \(minute) minutes age"
    } else {
        return "just now"
    }
}

public func removeFirstCharacter(from colorString: String) -> String {
    let index = colorString.index(after: colorString.startIndex)
    return String(colorString[index...])
}
