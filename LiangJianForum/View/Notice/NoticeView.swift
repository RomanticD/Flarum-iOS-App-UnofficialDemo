//
//  NoticeView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/1.
//

import SwiftUI

struct NoticeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("🧐 Message List") {
                    Text("Developing")
                }
                Section("🤩 Favorite Posts") {
                    Text("Developing")
                }
                Section("🥳 Followed Posts") {
                    Text("Developing")
                }
            }
            .navigationTitle("Notification Center")
        }
        
    }
}


//#Preview {
//    NoticeView()
//}
