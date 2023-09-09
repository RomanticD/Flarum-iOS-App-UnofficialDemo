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
        return NSLocalizedString("Invalid Date Format!", comment: "")
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

public func calculateTimeDifference(to dateString: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from: dateString) else {
        return NSLocalizedString("Invalid Date Format!", comment: "")
    }
    
    let currentTime = Date()
    let calendar = Calendar.current
    
    let components = calendar.dateComponents([.day, .hour, .minute], from: currentTime, to: date)
    
    if let day = components.day, day > 0 {
        return String.localizedStringWithFormat(NSLocalizedString("days later", comment: ""), day)
    } else if let hour = components.hour, hour > 0 {
        return String.localizedStringWithFormat(NSLocalizedString("hours later", comment: ""), hour)
    } else if let minute = components.minute, minute > 0 {
        return String.localizedStringWithFormat(NSLocalizedString("minutes later", comment: ""), minute)
    } else {
        return NSLocalizedString("very soon", comment: "")
    }
}



public func removeFirstCharacter(from colorString: String) -> String {
    let index = colorString.index(after: colorString.startIndex)
    return String(colorString[index...])
}

func getParentTagsFromFetching(from tags : [Datum6]) -> [Datum6]{
    var parentTags = [Datum6]()
    
    for item in tags{
        if !item.attributes.isChild{
            parentTags.append(item)
        }
    }
    return parentTags
}

func getChildTags(parentTag : Datum6, dataFetched: [Datum6]) -> [Datum6]{
    var childTags = [Datum6]()
    let parentTagId = parentTag.id
    
    for item in getChildTagsFromFetching(from: dataFetched){
        if let targetTagId = item.relationships?.parent.data.id{
            if targetTagId == parentTagId{
                childTags.append(item)
            }
        }
    }
    return childTags
}

func getChildTagsFromFetching(from tags : [Datum6]) -> [Datum6]{
    var childTags = [Datum6]()
    
    for item in tags{
        if item.attributes.isChild{
            childTags.append(item)
        }
    }
    return childTags
}

func getChildTagsId(parentTag : Datum6, dataFetched : [Datum6]) -> [String]? {
    var childTagsIds = [String]()
    let parentTagId = parentTag.id
    
    for childTag in getChildTagsFromFetching(from: dataFetched){
        if let targetTagId = childTag.relationships?.parent.data.id{
            if targetTagId == parentTagId{
                childTagsIds.append(childTag.id)
            }
        }
    }
    return childTagsIds
}
