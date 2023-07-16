//
//  NoticeView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/1.
//

import SwiftUI

struct NoticeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPageOffset = 0
    @State private var avatarUrl = ""
    @State private var selection : String = "🍿Comment"
    let filterOptions: [String] = ["🍿Comment", "🍺Like", "⛳️Follow"]
    @State private var userCommentData = [Datum8]()
    @State private var userCommentInclude = [Included8]()
    @EnvironmentObject var appsettings: AppSettings
    @State private var isLoading = false
    @State private var hasNextPage = false
    @State private var hasPrevPage = false
    @State private var searchTerm = ""
//    @State private var notificationData = [Datum7]()
//    @State private var notificationIncluded = [Included7]()
    
    var filteredCommentData : [Datum8] {
        var filteredItems: [Datum8] = []
        
        guard !searchTerm.isEmpty else { return userCommentData }
        
        for item in userCommentData {
            if let contentHtml = item.attributes.contentHTML {
                if contentHtml.htmlConvertedWithoutUrl.localizedCaseInsensitiveContains(searchTerm){
                    filteredItems.append(item)
                }
            }
        }
        return filteredItems
    }
    
    var body: some View {
        NavigationStack{
            if userCommentData.isEmpty || userCommentData.isEmpty{
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
            }else{
                Picker(
                    selection : $selection,
                    label: Text("Picker"),
                    content:{
                        ForEach(filterOptions.indices){index in
                            Text(filterOptions[index]).tag(filterOptions[index])
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 1), value: selection)

                if selection == "🍿Comment"{
                    CommentsView(
                        userCommentData: $userCommentData,
                        userCommentInclude: $userCommentInclude,
                        avatarUrl: $avatarUrl,
                        searchTerm: $searchTerm
                    )
                    .navigationTitle("Notification Center")
                }else if selection == "🍺Like"{
                    List{
                        Section("🤩Like"){
                            Text("Developing...")
                        }
                    }.navigationTitle("Notification Center")
                }else if selection == "⛳️Follow"{
                    List{
                        Section("🥳Follow"){
                            Text("Developing...")
                        }
                    }.navigationTitle("Notification Center")
                }else{
                    ProgressView()
                }
            }
        }
        .task {
            await fetchUserProfile()
            await fetchUserPosts()
        }
        
    }
//    private func fetchNotifications() async {
//
//        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/notifications") else{
//            print("Invalid Notification URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.setValue("Token \(appsettings.token)", forHTTPHeaderField: "Authorization")
//
//        do{
//            let (data, _) = try await URLSession.shared.data(for: request)
//
//            if let decodedResponse = try? JSONDecoder().decode(NotificationData.self, from: data){
//                self.notificationData = decodedResponse.data
//
//                if let included = decodedResponse.included{
//                    self.notificationIncluded = included
//                }
//
//                if decodedResponse.links.next != nil{
//                    self.hasNextPage = true
//                }
//
//                if decodedResponse.links.prev != nil && currentPage != 1{
//                    self.hasPrevPage = true
//                }else{
//                    self.hasPrevPage = false
//                }
//
//                print("successfully decode notification data")
//                print("current page: \(currentPage)")
//                print("has next page: \(hasNextPage)")
//                print("has prev page: \(hasPrevPage)")
//            }
//
//        } catch {
//            print("Invalid Notification Data!", error)
//        }
//    }

    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/users/\(appsettings.userId)") else{
            print("Invalid URL")
            return
        }
        print("Fetching User Info : id \(appsettings.userId) at: \(url)")

        do{
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                appsettings.username = decodedResponse.data.attributes.username

                if let avatarUrl = decodedResponse.data.attributes.avatarURL{
                    self.avatarUrl = avatarUrl
                }
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }

    private func fetchUserPosts() async {

        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(appsettings.username)&page%5Boffset%5D=\(currentPageOffset)") else{
            print("Invalid URL")
            return
        }

        do{
           print("fetching from \(url)")
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                print("successfully decode user's comment data")
                print("current page: \(currentPageOffset)")
                print("has next page: \(hasNextPage)")
                print("has prev page: \(hasPrevPage)")
            }

        } catch {
            print("Invalid user's comment Data!" ,error)
        }
    }
}


//#Preview {
//    NoticeView()
//}

