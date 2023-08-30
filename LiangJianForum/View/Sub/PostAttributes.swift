//
//  PostAttributes.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/29.
//

import SwiftUI

struct PostAttributes: View {
    var isSticky: Bool
    var isFrontPage: Bool?
    var isLocked: Bool
    var hasBestAnswer: Bool
    var hasPoll: Bool?
    
    var body: some View {
        HStack(spacing: 0) {
            if isSticky {
                Image(systemName: "eject.circle.fill")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "FFA500"))
                    .opacity(0.8)
            }
            
            if let hasVote = hasPoll{
                if hasVote{
                    Image(systemName: "hand.raised.circle")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "ce93d8"))
                        .opacity(0.8)
                }
            }
            
            if hasBestAnswer{
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.green)
                    .opacity(0.8)
            }
        
            if isLocked{
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.indigo)
                    .opacity(0.8)
            }
        
            if let hasFrontPage = isFrontPage{
                if hasFrontPage {
                    Image(systemName: "house.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.mint)
                        .opacity(0.8)
                }
            }
            
        }
        .padding(.leading)
    }
}

