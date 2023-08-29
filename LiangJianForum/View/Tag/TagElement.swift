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
//            Spacer()
            Image(systemName: "square.fill")
                .foregroundStyle(tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)))
                .font(.system(size: fontSize))
            
            Text(tag.attributes.name)
                .font(.system(size: fontSize))
                .bold()
                .padding(.leading,5)
//            Spacer()
        }
    }
}

