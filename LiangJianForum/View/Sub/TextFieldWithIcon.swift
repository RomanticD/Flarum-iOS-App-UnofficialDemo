//
//  TextFieldWithIcon.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/28.
//

import SwiftUI
import UIKit

struct TextFieldWithIcon: View {
    var iconName: String?
    @Binding var inputText: String
    var label: String
    @Binding var isAnimating: Bool
    @Binding var wrongInputRedBorder: CGFloat
    
    var body: some View {
        HStack {
            if let iconName = iconName {
                IconView(iconName: iconName)
            } else {
                EmptyView().frame(width: 30, height: 30)
            }
            
            TextField(label, text: $inputText)
                .foregroundColor(.gray)
                .padding()
                .frame(width: 300, height: 50)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .border(.red, width: wrongInputRedBorder)
                .disableAutocorrection(true)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
        .opacity(isAnimating ? 1 : 0)
        .animation(.easeInOut(duration: 1.5), value: isAnimating)
    }
}

struct IconView: View {
    var iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundColor(.gray)
            .frame(width: 30, height: 30)
    }
}


