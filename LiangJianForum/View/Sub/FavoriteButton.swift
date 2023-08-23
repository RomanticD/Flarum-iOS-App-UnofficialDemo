//
//  FavoriteButton.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/5.
//

import SwiftUI

struct FavoriteButton: View {
    @StateObject private var favoriteState = FavoriteState()
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    favoriteState.isFavorite.toggle()
                }
            }) {
                Image(systemName: favoriteState.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 15))
                    .foregroundColor(favoriteState.isFavorite ? .yellow : Color(UIColor.quaternaryLabel))
            }
            .buttonStyle(.plain)
        }
    }
}

class FavoriteState: ObservableObject {
    @Published var isFavorite = false
}


//#Preview {
//    FavoriteButton()
//}
