//
//  CommentsView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/7/16.
//

import SwiftUI

struct CommentsView: View {
    var username: String
    var displayname: String?
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var userCommentData: [Datum8]
    @Binding var userCommentInclude: [Included8]
    var avatarUrl: String
    @Binding var searchTerm: String
    @EnvironmentObject var appsettings: AppSettings
    @State private var currentPageOffset = 0
    @State private var isLoading = false
    @State private var hasNextPage = false
    @State private var hasPrevPage = false
    @State private var copiedText: String?
    
    private var isUserVIP: Bool {
        return appsettings.vipUsernames.contains(username)
    }
    
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
        PaginationView(hasPrevPage: hasPrevPage,
                       hasNextPage: hasNextPage,
                       currentPage: $currentPageOffset,
                       isLoading: $isLoading,
                       fetchDiscussion: nil,
                       fetchUserInfo: fetchUserCommentsData(completion:),
                       mode: .offset
        )
        
        ScrollViewReader { proxy in
            if userCommentData.isEmpty{
                CommentsViewContentLoader()
            }else{
                List{
                    ForEach(filteredCommentData, id: \.id)  {item in
                        let DiscussionId = item.relationships.discussion.data.id
                        let DiscussionTitle = findDiscussionTitle(id: item.relationships.discussion.data.id)
                        var CommentCount = 0
                        let sectionTitle = NSLocalizedString("🍾 In", comment: "") + " \"" + DiscussionTitle + "\""

                        
                        if item.attributes.contentType == "comment"{
                            Section(sectionTitle){
                                if let contentHtml = item.attributes.contentHTML{
                                    NavigationLink(value: item){
                                        VStack{
                                            HStack{
                                                if avatarUrl != ""{
                                                    if isUserVIP{
                                                        AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 50, lineWidth: 1.2, shadow: 3, strokeColor : Color(hex: "FFD700"))
                                                            .padding(.top, 10)
                                                    }else{
                                                        AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 50, lineWidth: 1, shadow: 3)
                                                            .padding(.top, 10)
                                                    }
                                                } else {
                                                    CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                        .opacity(0.3)
                                                        .padding(.top, 10)
                                                }
                                                
                                                if let displayname = self.displayname{
                                                    Text(displayname)
                                                        .shimmering(active: isUserVIP)
                                                        .font(.system(size: 12))
                                                        .bold()
                                                        .padding(.leading, 3)
                                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                                }else{
                                                    Text(username)
                                                        .font(.system(size: 12))
                                                        .bold()
                                                        .padding(.leading, 3)
                                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                                }
                                                
                                                Text(calculateTimeDifference(from: item.attributes.createdAt))
                                                    .font(.system(size: 8))
                                                    .foregroundColor(.gray)
                                                
                                                if let editedTime = item.attributes.editedAt{
                                                    Text("Edited")
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.gray)
                                                        .italic()
                                                }
                                                
                                                Spacer()
                                            }
                                            .task{
                                                CommentCount = await fetchCommentCount(DiscussionId)
                                            }
                                            
                                            CommentDisplayView(copiedText: $copiedText, contentHTML: item.attributes.contentHTML)

                                        }
                                        .navigationDestination(for: Datum8.self){item in
                                            PostDetailView(
                                                postTitle: findDiscussionTitle(id: item.relationships.discussion.data.id),
                                                postID: item.relationships.discussion.data.id,
                                                commentCount: CommentCount
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .id("AllUserComments")
                }
                .refreshable {
                    isLoading = true
                    fetchUserCommentsData{success in
                        if success{
                            isLoading = false
                        }else{
                            
                        }
                    }
                    
//                    Task{
//                        await fetchUserPostsInfo()
//                    }
                }
                .onAppear{
                    isLoading = true
                    fetchUserCommentsData{success in
                        if success{
                            isLoading = false
                        }else{
                            
                        }
                    }
                    
//                    Task{
//                        await fetchUserPostsInfo()
//                    }
                }
                .onChange(of: currentPageOffset){ _ in
                    withAnimation {
                        proxy.scrollTo("AllUserComments", anchor: .top)
                    }
                }
//                .searchable(text: $searchTerm, prompt: "Search")
            }
        }
        .navigationTitle("最新动态")
    }
        
    private func findDiscussionTitle(id: String) -> String{
        var title = ""
        for item in userCommentInclude{
            if item.type == "discussions" && item.id == id{
                if let titleIn = item.attributes.title{
                    title = titleIn
                }
            }
        }
        return title
    }
        
    private func fetchCommentCount(_ id: String) async -> Int{
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/discussions/\(id)") else{
            print("Invalid URL")
            return 0
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(DiscussionDataWithId.self, from: data){
                return decodedResponse.data.attributes.commentCount
            }
            
        } catch {
            print("Invalid Discussions Data In method fetchCommentCount()!" ,error)
        }
        
        return 0
    }
   
    private func fetchUserCommentsData(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else {
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

