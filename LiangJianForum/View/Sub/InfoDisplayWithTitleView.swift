//
//  InfoDisplayWithTitleView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/20.
//

import SwiftUI

struct InfoDisplayWithTitleView: View {
    var title: String
    var displayText: Binding<String>
    var titleIcon: String
    var frameHeight : CGFloat
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: titleIcon)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                    .padding(.leading, 55)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            
            Text(displayText.wrappedValue)
                .foregroundColor(.black)
                .frame(width: 500, height: frameHeight)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .bold()
                .opacity(0.7)
        }
    }
}

//struct InfoDisplayWithTitleView_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoDisplayWithTitleView(
//            title: "昵称",
//            displayText: .constant("Your nickname"),
//            titleIcon: "person.badge.shield.checkmark",
//            frameHeight: 300
//        )
//    }
//}

