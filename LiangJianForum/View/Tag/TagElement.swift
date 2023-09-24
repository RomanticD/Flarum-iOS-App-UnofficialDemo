//
//  TabElement.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/27.
//

import SwiftUI
import Awesome

struct TagElement: View {
    let tag: Datum6
    let fontSize : CGFloat
    
    var body: some View {
        HStack {
            ZStack{
                Image(systemName: "square.fill")
                    .foregroundColor(tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)))
                    .font(.system(size: fontSize + 5))
                    .opacity(0.8)
                
                if let iconStringFromFetching = formatIconString(getIconNameFromFetching(from: tag.attributes.icon)), let iconCode = translate(iconStringFromFetching, forEnum: Awesome.Solid.self) {
                    if let icon = Awesome.Solid(rawValue: iconCode.rawValue){
                        icon.image
                            .size(fontSize - 2)
                            .foregroundColor(.white)
                    }
                    
                } else {
                    Image(systemName: "square.fill")
                        .foregroundColor(tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)))
                        .font(.system(size: fontSize + 5))
                        .opacity(0.8)
                }
            }
            
            
            Text(tag.attributes.name)
                .font(.system(size: fontSize))
                .bold()
                .padding(.leading,5)
        }
    }
}

