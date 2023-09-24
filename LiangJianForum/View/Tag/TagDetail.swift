//
//  TagDetail.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/26.
//

import SwiftUI

struct TagDetail: View {
    let selectedTag : Datum6
    
    @State private var currentPageOffset = 0
    @State private var isLoading = false
    @State private var hasNextPage = false
    @State private var hasPrevPage = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showingPostingArea = false
    @State private var discussionData = [Datum]()
    @State private var discussionIncluded = [Included]()
    @State private var discussionLinksFirst : String = ""
    @EnvironmentObject var appsettings: AppSettings
    @State private var searchTerm = ""
    
    private func findDisplayName(_ userid: String, in array: [Included]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            if let displayName = item.attributes.displayName{
                return displayName
            }
        }
        return nil
    }
   
    var filteredDiscussionData : [Datum] {
        var filteredItems: [Datum] = []
        var filteredByTitle: [Datum] = []
        var filteredByDisplayName: [Datum] = []
        
        guard !searchTerm.isEmpty else { return discussionData }
        
        for item in discussionData {

            if item.attributes.title.localizedCaseInsensitiveContains(searchTerm) {
                filteredByTitle.append(item)
            }

            if let displayName = findDisplayName(item.id, in: discussionIncluded) {
                if displayName.localizedCaseInsensitiveContains(searchTerm){
                    filteredByDisplayName.append(item)
                }
            }
        }
        filteredItems.append(contentsOf: filteredByTitle)
        filteredItems.append(contentsOf: filteredByDisplayName)
        
        return filteredItems
    }
    
    var body: some View {
        VStack {
            if discussionData.isEmpty {
                TagDetailViewContentLoader(selectedTag: selectedTag)
            } else {
                PaginationView(hasPrevPage: hasPrevPage, hasNextPage: hasNextPage, currentPage: $currentPageOffset, isLoading: $isLoading, fetchDiscussion: nil, fetchUserInfo: fetchDiscussionData(completion:), mode: .offset)

                ScrollViewReader { proxy in
                    List {
                        Section{
                            ForEach(filteredDiscussionData, id: \.id) { item in
                                let subscription = item.attributes.subscription ?? ""
                                let isSubscription = (subscription == "follow")
                                if item.attributes.lastPostedAt != nil{
                                    HStack {
                                        VStack {
                                            NavigationLink(value: item){
                                                //MARK: 头像及标题
                                                HStack{
                                                    if let user = findUser(with: item.relationships.user.data.id) {
                                                        if let avatarURL = user.attributes.avatarUrl, let user_name = user.attributes.username {
                                                            if isUserVip(username: user_name){
                                                                AvatarAsyncImage(url: URL(string: avatarURL), frameSize: 40, lineWidth: 1.2, shadow: 3, strokeColor : Color(hex: "FFD700"))
                                                            }else{
                                                                AvatarAsyncImage(url: URL(string: avatarURL), frameSize: 40, lineWidth: 1, shadow: 3)
                                                            }
                                                        } else {
                                                            CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 40, lineWidth: 1, shadow: 3)
                                                                .opacity (0.3)
                                                        }
                                                    }
                                                    
                                                    VStack {
                                                        HStack {
                                                            Text(item.attributes.title)
                                                                .font(.system(size: 20))
                                                                .foregroundColor(
                                                                    item.attributes.isSticky ?//置顶贴子标题为红色
                                                                    Color.red :
                                                                    (item.attributes.frontpage ?? false ?
                                                                        Color.blue ://精华帖子标题为蓝色
                                                                        (colorScheme == .dark ? Color(hex: "EFEFEF") : Color(hex: "243B55")))
                                                                )
                                                                .bold()
                                                                .fixedSize(horizontal: false, vertical: true)
                                                                .padding(.leading)
                                                                .lineLimit(2)
                                                            Spacer()
                                                        }


                                                    }
                                                    Spacer()
                                                }
                                            }
                                            
                                            //MARK: 最后更新时间 评论数 阅读数量 收藏
                                            HStack {
                                                Image(systemName: "clock.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 10))
                                                
                                                if let lastPostedAt = item.attributes.lastPostedAt {
                                                    Text(calculateTimeDifference(from: lastPostedAt))
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.gray)
                                                } else {
                                                    Text("in review...")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Image(systemName: "bubble.middle.bottom.fill")
                                                    .foregroundColor(.gray)
                                                    .padding(.leading)
                                                    .font(.system(size: 10))
                                                Text("\(item.attributes.commentCount)")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 10))
                                                
                                                if let viewcount = item.attributes.viewCount{
                                                    Image(systemName: "eye.fill")
                                                        .foregroundColor(.gray)
                                                        .padding(.leading)
                                                        .font(.system(size: 10))
                                                    Text("\(viewcount)")
                                                        .foregroundColor(.gray)
                                                        .font(.system(size: 10))
                                                }
                                                
                                                PostAttributes(isSticky: item.attributes.isSticky, isFrontPage: item.attributes.frontpage, isLocked: item.attributes.isLocked, hasBestAnswer: checkIfHasBestAnswer(dataIn: item.attributes.hasBestAnswer), hasPoll: item.attributes.hasPoll)
                                                
                                                FavoriteButton(isSubscription: isSubscription, discussionId: item.id)
                                                
                                            }
                                            .padding(.top, 10)
                                            .padding(.bottom, 5)

                                            Divider()
                                        }
                                    }
//                                        .listRowBackground(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                        .id("TagDetailList")
                    }
                    .onChange(of: currentPageOffset) { _ in
                        withAnimation {
                            isLoading = true
                            proxy.scrollTo("TagDetailList", anchor: .top)
                            isLoading = false
                        }
                    }
                    .textSelection(.enabled)
//                    .searchable(text: $searchTerm, prompt: "Search")
                    .sheet(isPresented: $showingPostingArea) {
                        newPostView().environmentObject(appsettings)
                            .presentationDetents([.medium, .large])
                    }
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationTitle(self.selectedTag.attributes.name)
                    .toolbarBackground(selectedTag.attributes.color.isEmpty ? Color.gray.opacity(0.8) : Color(hex: removeFirstCharacter(from: selectedTag.attributes.color)).opacity(0.8), for: .automatic)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: Datum.self){item in
                        PostDetailView(postTitle: item.attributes.title, postID: item.id, commentCount: item.attributes.commentCount).environmentObject(appsettings)
                    }
                    .navigationBarItems(trailing:
                        Menu {
                            Section(NSLocalizedString("tabbar_operations", comment: "")){
                                Button {
                                    showingPostingArea.toggle()
                                } label: {
                                    Label(NSLocalizedString("start_new_discussion_message", comment: ""), systemImage: "plus.bubble.fill")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    )
                }
            }
        }
        .refreshable {
            isLoading = true
            fetchDiscussionData { success in
                if success{
                    
                }
                isLoading = false
            }
        }
        .onAppear {
            isLoading = true
            fetchDiscussionData { success in
                if success{
                    
                }
                isLoading = false
            }
        }

    }
    
    private func checkIfHasBestAnswer(dataIn: HasBestAnswer?) -> Bool {
        var hasBestAnswer = false
        
        if let bestAnswerData = dataIn{
            switch bestAnswerData {
            case .integer:
                hasBestAnswer = true
            default:
                hasBestAnswer = false
            }
        }
        return hasBestAnswer
    }
    
    private func findUser(with id: String) -> Included? {
        for item in discussionIncluded {
            if item.type == "users" && item.id == id {
                return item
            }
        }
        return nil
    }
    
    private func isUserVip(username: String) -> Bool{
        return appsettings.vipUsernames.contains(username)
    }
    
    private func fetchDiscussionData(completion: @escaping (Bool) -> Void){
        var url: URL? = nil // 声明url变量并初始化为nil
        
       
        url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?include=user%2ClastPostedUser%2Ctags%2Ctags.parent%2CfirstPost&filter%5Btag%5D=\(selectedTag.attributes.slug)&sort=&page%5Boffset%5D=\(currentPageOffset)")
        
        
        print("fetching from url: \(String(describing: url))")
        
        // 检查url是否为nil
        guard let url = url else {
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
            print("Invalid Token Or Not Logged in Yet!")
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
                if let decodedResponse = try? JSONDecoder().decode(Discussion.self, from: data) {
                    print("Successfully decoding use Discussion.self")
                    discussionData = decodedResponse.data ?? []
                    discussionIncluded = decodedResponse.included
                    discussionLinksFirst = decodedResponse.links.first
                    
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
                    
                    print("successfully decode discussions data")
                } else {
                    print("Invalid Discussions Overview And Title Data!")
                }
            }
            
            // 请求成功后调用回调
            completion(true)
            
        }.resume()
    }
}

