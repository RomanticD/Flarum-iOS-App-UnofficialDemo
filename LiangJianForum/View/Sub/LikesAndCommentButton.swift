//
//  LikesAndCommentButton.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/27.
//

import SwiftUI

struct LikesAndCommentButton: View {
    @StateObject private var likesAndCommentState = LikesAndCommentState()
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    likesAndCommentState.isLiked.toggle()
                }
            }) {
                Image(systemName: likesAndCommentState.isLiked ? "heart.fill" : "heart")
                    .frame(width: 12, height: 12)
                    .foregroundColor(likesAndCommentState.isLiked ? .red : .blue)
            }
            .buttonStyle(.plain)
            .padding(.trailing)
            
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    likesAndCommentState.isComment.toggle()
                }
            }) {
                Image(systemName: likesAndCommentState.isComment ? "arrowshape.turn.up.left.fill" : "arrowshape.turn.up.left")
                    .frame(width: 12, height: 12)
                    .foregroundColor(likesAndCommentState.isComment ? .mint : .blue)
            }
            .buttonStyle(.plain)
            .padding(.trailing)
        }
    }
}

class LikesAndCommentState: ObservableObject {
    @Published var isLiked = false
    @Published var isComment = false
}


//#Preview {
//    LikesAndCommentButton()
//}
