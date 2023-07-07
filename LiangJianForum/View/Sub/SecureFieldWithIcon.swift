//
//  SecurefieldWithIcon.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/28.
//

import SwiftUI

struct SecureFieldWithIcon: View {
    var passwordIconName: String?
    @Binding var inputPassword: String
    var passwordLabel: String
    @Binding var isAnimatingNow: Bool
    @Binding var wrongPasswordRedBorder: CGFloat
    
    var body: some View {
        HStack {
            if let iconName = passwordIconName {
                IconView(iconName: iconName)
            } else {
                Spacer().frame(width: 40, height: 30)
            }
            
            SecureField(passwordLabel, text: $inputPassword)
                .foregroundColor(.gray)
                .padding()
                .frame(width: 300, height: 50)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .border(.red, width: wrongPasswordRedBorder)
        }
        .opacity(isAnimatingNow ? 1 : 0)
        .animation(.easeInOut(duration: 1.5), value: isAnimatingNow)
    }
}
