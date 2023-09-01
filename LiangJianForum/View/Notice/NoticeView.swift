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
    @State private var selection : String = NSLocalizedString("comment_sector", comment: "")
    let filterOptions: [String] = [NSLocalizedString("comment_sector", comment: ""), NSLocalizedString("like_sector", comment: ""), NSLocalizedString("follow_sector", comment: "")]
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
            ScrollViewReader{ proxy in
                VStack{
                    if userCommentData.isEmpty || userCommentData.isEmpty{
                        HStack {
                            Text("Loading...").foregroundStyle(.secondary)
                            ProgressView()
                        }
                    }else{
                        if selection == NSLocalizedString("comment_sector", comment: ""){
                            CommentsView(
                                username: appsettings.username,
                                userCommentData: $userCommentData,
                                userCommentInclude: $userCommentInclude,
                                avatarUrl: $avatarUrl,
                                searchTerm: $searchTerm
                            )
                        }else if selection == NSLocalizedString("like_sector", comment: ""){
                            List{
                                Section("🤩Like"){
                                    Text("Developing...")
                                }
                            }
                        }else if selection == NSLocalizedString("follow_sector", comment: ""){
                            List{
                                Section("🥳Follow"){
                                    Text("Developing...")
                                }
                            }
                        }else{
                            ProgressView()
                        }
                    }
                }
                .id("Top")
                .task {
                    await fetchUserProfile()
                    await fetchUserPosts()
                }
                .navigationTitle("Notification Center")
                .navigationBarItems(trailing:
                    Menu {
                        Section(NSLocalizedString("sorted_by_text", comment: "")){
                            Button {
                                //选择默认的逻辑
                                proxy.scrollTo("Top", anchor: .top)
                                selection = NSLocalizedString("comment_sector", comment: "")
                            } label: {
                                Label(NSLocalizedString("comment_sector", comment: ""), systemImage: "seal")
                            }
                        
                            Button {
                                //选择最新帖子的逻辑
                                proxy.scrollTo("Top", anchor: .top)
                                selection = NSLocalizedString("like_sector", comment: "")
                            } label: {
                                Label(NSLocalizedString("like_sector", comment: ""), systemImage: "timer")
                            }
                            
                            Button {
                                //选择最新回复的逻辑
                                proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                selection = NSLocalizedString("follow_sector", comment: "")
                            } label: {
                                Label(NSLocalizedString("follow_sector", comment: ""), systemImage: "message.badge")
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                )
            }
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

    public func fetchUserProfile() async {
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

    public func fetchUserPosts() async {

        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(appsettings.username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
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
                print("current page offset: \(currentPageOffset)")
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

