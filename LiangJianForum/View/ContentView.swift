//
//  MainPage.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appsettings: AppSettings
    @State private var selection: Tab = .post
    
    enum Tab {
        case post
        case profile
        case tag
        case notice
    }
    
    var body: some View {
        if appsettings.isLoggedIn {
            TabView(selection: $selection) {
                PostView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.post)
                    .environmentObject(appsettings)
                
                TagField()
                    .tabItem { Label("Tag", systemImage: "tag.square") }
                    .tag(Tab.tag)
                
                NoticeView()
                    .tabItem { Label("Message", systemImage: "bell.fill") }
                
                ProfileView()
                    .tabItem { Label("Me", systemImage: "person.crop.rectangle.stack") }
                    .tag(Tab.profile)
            }
            .environmentObject(appsettings)
        } else {
            LoginPageView()
                .environmentObject(appsettings)
        }
    }
}

//#Preview {
//    ContentView()
//}

