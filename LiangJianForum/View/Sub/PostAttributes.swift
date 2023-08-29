//
//  PostAttributes.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/29.
//

import SwiftUI

struct PostAttributes: View {
    var isSticky: Bool
    var isFrontPage: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if isSticky {
                Image(systemName: "z.square.fill")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "FFA500"))
                    .opacity(0.8)
            }
            
            if isFrontPage {
                Image(systemName: "j.square.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.mint)
                    .opacity(0.8)
            }
        }
        .padding(.leading)
    }
}

