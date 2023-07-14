//
//  TabElement.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/27.
//

import SwiftUI

struct TagElement: View {
    let tag: Datum6
    let fontSize : CGFloat
    
    var body: some View {
        HStack {
            Image(systemName: "square.fill")
                .foregroundStyle(tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)))
                .font(.system(size: fontSize))
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            Text(tag.attributes.name)
                .font(.system(size: fontSize))
                .bold()
                .padding(.top, 10)
                .padding(.bottom,10)
                .padding(.leading,5)
        }
    }
}

