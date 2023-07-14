//
//  TagButton.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/7/14.
//

import SwiftUI

struct TagButton: View {
    let id: String
    let tagColor: Color
    let title: String
    @Binding var selectedButtonIds: [String]
    @Environment(\.colorScheme) var colorScheme
    
    var isSelected: Bool {
        selectedButtonIds.contains(id)
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                selectedButtonIds.removeAll(where: { $0 == id })
            } else {
                selectedButtonIds.append(id)
            }
        }) {
            Text(title)
                .foregroundColor(isSelected ? Color.white : Color.black)
                .font(.system(size: 12))
                .padding()
                .lineLimit(1)
                .background(isSelected ? tagColor : colorScheme == .dark ? Color(hex: "AAAAAA") : Color.white)
                .frame(height: 36)
                .cornerRadius(18)
                .overlay(Capsule().stroke(tagColor, lineWidth: 2))
        }
    }
}
