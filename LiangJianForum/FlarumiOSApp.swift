//
//  LiangJianForumApp.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI

@main
struct FlarumiOSApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            LoginPageView()
                .environmentObject(appSettings)
        }
    }
}
