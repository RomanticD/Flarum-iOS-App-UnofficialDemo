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
    let parentId: String?
    let childTagsId: [String]?
    @Binding var selectedButtonIds: [String]
    @Environment(\.colorScheme) var colorScheme
    
    var isSelected: Bool {
        selectedButtonIds.contains(id)
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                selectedButtonIds.removeAll(where: { $0 == id })
                
                if let childTagsId = childTagsId {
                    selectedButtonIds = selectedButtonIds.filter { !childTagsId.contains($0) }
                }
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
        .disabled(parentId != nil && !isParentTagSeleted())
        .opacity(calculateOpacity())
    }
    
    private func isParentTagSeleted() -> Bool {
        if let parentTagId = self.parentId{
            return selectedButtonIds.contains(parentTagId)
        }else{
            return false
        }
    }
    
    private func calculateOpacity() -> Double {
        if let parentTagId = self.parentId {
            return selectedButtonIds.contains(parentTagId) ? 1.0 : 0.0
        } else {
            return 1.0 // 如果没有父标签，将其视为已选中
        }
    }
}
