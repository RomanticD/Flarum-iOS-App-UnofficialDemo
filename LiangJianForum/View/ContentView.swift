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
                    .tag(Tab.notice)
                
                ProfileView()
                    .tabItem { Label("Me", systemImage: "person.crop.rectangle.stack") }
                    .tag(Tab.profile)
            }
            .onAppear{
                Task{
                    await retrieveCurrentUserInformation()
                }
            }
            .environmentObject(appsettings)
        } else {
            LoginPageView()
                .environmentObject(appsettings)
        }
    }
    
    private func retrieveCurrentUserInformation() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/users/\(appsettings.userId)") else{
            print("Invalid URL")
            return
        }
        print("Fetching User Info : id \(appsettings.userId) at: \(url)")

        do{
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                appsettings.username = decodedResponse.data.attributes.username
                appsettings.displayName = decodedResponse.data.attributes.displayName

                if let avatarUrl = decodedResponse.data.attributes.avatarURL{
                    appsettings.avatarUrl = avatarUrl
                }
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }
}


