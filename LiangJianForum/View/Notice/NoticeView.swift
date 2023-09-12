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
    @State private var displayName = ""
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
                        CommentsViewContentLoader()
                    }else{
                        if selection == NSLocalizedString("comment_sector", comment: ""){
                            CommentsView(
                                username: appsettings.username,
                                displayname: appsettings.displayName,
                                userCommentData: $userCommentData,
                                userCommentInclude: $userCommentInclude,
                                avatarUrl: appsettings.avatarUrl,
                                searchTerm: $searchTerm
                            )
                        }else if selection == NSLocalizedString("like_sector", comment: ""){
                            LikedCommentsView(
                                              userId: String(appsettings.userId),
                                              userCommentInclude: $userCommentInclude,
                                              searchTerm: $searchTerm
                            )
                        }else if selection == NSLocalizedString("money_sector", comment: ""){
                            MoneyConditionRecord(Usermoney: nil, userId: String(appsettings.userId))
                        }else{
                            ProgressView()
                        }
                    }
                }
                .id("Top")
                .task {
                    fetchUserCommentsData { success in
                        if success{
                            
                        }else{
                            
                        }
                    }
                }
                .onAppear{
                    fetchUserCommentsData { success in
                        if success{
                            
                        }else{
                            
                        }
                    }
                }
                .navigationTitle("Notification Center")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Menu {
                        Section(NSLocalizedString("tabbar_operations", comment: "")){
                            Button {
                                //选择评论
                                proxy.scrollTo("Top", anchor: .top)
                                
                                clearData()
                                fetchUserCommentsData { success in
                                    if success{
                                        
                                    }else{
                                        
                                    }
                                }
                                
                                selection = NSLocalizedString("comment_sector", comment: "")
                            } label: {
                                Label(NSLocalizedString("comment_sector", comment: ""), systemImage: "bubble.left")
                            }
                        
                            Button {
                                //选择点赞
                                proxy.scrollTo("Top", anchor: .top)
                                
                                clearData()
                                fetchUserCommentsData { success in
                                    if success{
                                        
                                    }else{
                                        
                                    }
                                }
                                
                                selection = NSLocalizedString("like_sector", comment: "")
                            } label: {
                                Label(NSLocalizedString("like_sector", comment: ""), systemImage: "heart")
                            }
                            
                            Button {
                                //选择查看资产
                                proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                
                                clearData()
                                fetchUserCommentsData { success in
                                    if success{
                                        
                                    }else{
                                        
                                    }
                                }
                                
                                selection = NSLocalizedString("money_sector", comment: "")
                            } label: {
                                Label(NSLocalizedString("money_sector", comment: ""), systemImage: "dollarsign.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                )
            }
        }
        
    }
    
    private func clearData(){
        self.userCommentData = []
        self.userCommentInclude = []
    }
    
    private func fetchUserCommentsData(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(appsettings.username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        // 创建URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 使用GET方法
        
        // 设置请求头
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appsettings.token != "" {
            request.setValue("Token \(appsettings.token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Invalid Token or Not Logged in Yet!")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                completion(false)
                return
            }
            
            // 在请求成功时处理数据
            if let data = data {
                print("fetching from \(url)")
                print("In CommentsView")
                
                if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data) {
                    self.userCommentData = decodedResponse.data
                    self.userCommentInclude = decodedResponse.included

                    if decodedResponse.links.next == nil || decodedResponse.links.next == "" {
                        self.hasNextPage = false
                    } else {
                        self.hasNextPage = true
                    }
                    
                    if decodedResponse.links.prev != nil && currentPageOffset != 0 {
                        self.hasPrevPage = true
                    } else {
                        self.hasPrevPage = false
                    }

                    print("successfully decode user's comment data")
                    print("current page offset: \(currentPageOffset)")
                    print("has next page: \(hasNextPage)")
                    print("has prev page: \(hasPrevPage)")
                } else {
                    print("Invalid user's comment Data!")
                }
            }
            
            // 请求成功后调用回调
            completion(true)
            
        }.resume()
    }
}


//#Preview {
//    NoticeView()
//}

