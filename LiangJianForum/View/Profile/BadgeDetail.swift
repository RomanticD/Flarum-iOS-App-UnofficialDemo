//
//  BadgeDetail.swift
//  LiangJian iOS App
//
//  Created by Romantic D on 2023/9/14.
//

import SwiftUI
import Awesome

struct BadgeDetail: View {
    let badge : UserInclude
    
    var body: some View {
        VStack{
            List{
                Section{
                    let badgeName = badge.attributes.name ?? "Invalid badge name"
                    let description = badge.attributes.description ?? "Invalid badge description"
                    let earnedAmount = badge.attributes.earnedAmount ?? 0
                    let createdAt = badge.attributes.createdAt ?? ""

                    HStack{
                        Text("徽章图标: ")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                        
                        ZStack{
                            let icon = badge.attributes.icon
                            if let iconColor = badge.attributes.backgroundColor{
                                Image(systemName: "square.fill")
                                    .foregroundColor(iconColor.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: iconColor)))
                                    .font(.system(size: 40 + 5))
                                    .opacity(0.9)
                                
                                if let iconStringFromFetching = formatIconString(getIconNameFromFetching(from: icon)), let iconCode = translate(iconStringFromFetching, forEnum: Awesome.Solid.self) {
                                    if let icon = Awesome.Solid(rawValue: iconCode.rawValue){
                                        icon.image
                                            .size(40 - 2)
                                            .foregroundColor(.white)
                                    }
                                    
                                } else {
                                    Image(systemName: "square.fill")
                                        .foregroundColor(iconColor.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: iconColor)))
                                        .font(.system(size: 40 + 5))
                                        .opacity(0.9)
                                }
                            }
                        }
                        
                    }
                    .padding(.vertical)
                    
                    HStack{
                        Text("徽章名称: ")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                        
                        Text(badgeName)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                    }
                    .padding(.vertical)
                    
                    HStack{
                        Text("徽章描述: ")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                        
                        Text(description)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical)
                    
                    HStack{
                        Text("获得人数: ")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                        
                        Text(String(earnedAmount))
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                    }
                    .padding(.vertical)
                    
                    HStack{
                        Text("首次颁发: ")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                        
                        Text(calculateTimeDifference(from: createdAt))
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle(badge.attributes.name ?? "Invalid badge name")
    }
}
