//
//  PostDetial.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/30.
//

import SwiftUI
import Shimmer

struct PostDetailView: View {
    let postTitle: String
    let postID: String
    let commentCount: Int
    
    var sortOption = [NSLocalizedString("default_sort_option", comment: ""), NSLocalizedString("latest_sort_option", comment: "")]
    
    @State private var selectedSortOption = NSLocalizedString("default_sort_option", comment: "")
    @State private var currentPage = 1
    @State private var isLoading = false
    @State private var isSubViewLoading = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appsettings: AppSettings
    @State private var showingPostingArea = false
    @State private var isLiked = false
    @State private var isReplied = false
    @State private var include = [Included5]()
    @State var postsArray: [Included5] = []
    @State var usersArray: [Included5] = []
    @State var polls: [Included5] = []
    @State var pollOptions: [Included5] = []
    @State private var searchTerm = ""
    @State private var fetchedTags = [Datum6]()
    @State private var showedTags = [Datum6]()
    @State var tagsIdInPostDetail: [String] = []
    @State private var copiedText: String?
    @State private var postsData : DataClass5?

    var filteredPosts: [Included5] {
        var filteredItems: [Included5] = []
        var filteredByContent: [Included5] = []
        var filteredByDisplayName: [Included5] = []
        
        guard !searchTerm.isEmpty else { return postsArray }
        
        for item in postsArray {
            if let content = item.attributes.contentHTML {
                if content.htmlConvertedWithoutUrl.localizedCaseInsensitiveContains(searchTerm) {
                    filteredByContent.append(item)
                }
            }
            
            if let userid = item.relationships?.user?.data.id {
                let userInfo = getUserInfo(userid, in: usersArray)
                if let displayName = userInfo.displayName, displayName.localizedCaseInsensitiveContains(searchTerm) {
                    filteredByDisplayName.append(item)
                }
            }
        }
        
        filteredItems.append(contentsOf: filteredByContent)
        filteredItems.append(contentsOf: filteredByDisplayName)
        
        return filteredItems
    }
    
    var shadowColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
        VStack {
            if include.isEmpty {
                PostDetailViewContentLoader(postTitle: postTitle, postID: postID, commentCount: commentCount)
            } else {
                if !tagsIdInPostDetail.isEmpty {
                    HStack {
                        Spacer()
                        ForEach(fetchedTags, id: \.id) { tag in
                            if tagsIdInPostDetail.contains(tag.id) {
                                if getChildTags(parentTag: tag, dataFetched: fetchedTags).isEmpty{
                                    NavigationLink(value: tag){
                                        TagElement(tag: tag, fontSize: 15)
                                    }
                                }else{
                                    NavigationLink(value: getChildTags(parentTag: tag, dataFetched: fetchedTags)){
                                        TagElement(tag: tag, fontSize: 15)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                
                ZStack(alignment: .bottomTrailing) {
                    List{
                        if (postsArray.isEmpty){
                            Section{
                                EmptyView()
                            }
                        }else{
                            // MARK: - If current discussion has votes
                            if !self.polls.isEmpty{
                                Section("当前投票"){
                                    VStack{
                                        ForEach(polls, id: \.id) { poll in
                                            PollChartView(pollOptionsAndVoteCount: findPollOptionsAndVoteCount(poll: poll),
                                                          AnswerWithId: findAnswerWithId(),
                                                          voteQuestion: poll.attributes.question,
                                                          endDate: poll.attributes.endDate,
                                                          canVote: poll.attributes.canVote,
                                                          pollId: poll.id,
                                                          allowMultipleVotes: poll.attributes.allowMultipleVotes,
                                                          maxVotes: poll.attributes.maxVotes,
                                                          allowChangeVote: poll.attributes.canChangeVote
                                            )
                                        }
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            
                                        }) {
                                            Label("完成查看", systemImage: "eyes")
                                        }
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                            }
                            
                            Section("帖子回复"){
                                // MARK: - Post list
                                ForEach(filteredPosts, id: \.id){item in
                                    let isHidden = isPostHidden(post: item)
                                    
                                    VStack {
                                        HStack {
                                            VStack {
                                                NavigationLink(value: item){
                                                    ZStack (alignment: .bottomLeading){
                                                        HStack {
                                                            if let userid = item.relationships?.user?.data.id{
                                                               let userInfo = getUserInfo(userid, in: usersArray)
                                                                
                                                                let avatarURL = userInfo.avatarURL ?? ""
                                                                let username = userInfo.username ?? "Invalid Username"
                                                                
                                                                //用户头像
                                                                if isUserVip(identifier: username) && avatarURL != "" {
                                                                    AvatarAsyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1.2, shadow: 3, strokeColor: Color(hex: "FFD700"))
                                                                        .padding(.top, 10)
                                                                        .padding(.leading, 6)
                                                                        .offset(x: 0, y: -10)
                                                                } else if avatarURL != "" {
                                                                    AvatarAsyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                                                                        .padding(.top, 10)
                                                                        .padding(.leading, 6)
                                                                        .offset(x: 0, y: -10)
                                                                } else {
                                                                    CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                                        .opacity(0.3)
                                                                        .padding(.top, 10)
                                                                        .padding(.leading, 6)
                                                                        .offset(x: 0, y: -10)
                                                                }
                                                            }
                                                            
                                                            //用户昵称
                                                            if let userid = item.relationships?.user?.data.id {
                                                                let userInfo = getUserInfo(userid, in: usersArray)
                                                                
                                                                
                                                                Text(userInfo.displayName ?? (userInfo.username ?? "Invalid Username"))
                                                                    .shimmering(active: isUserVip(identifier: userInfo.username ?? "Invalid Username"))
                                                                    .font(.system(size: 12))
                                                                    .bold()
                                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                                    .padding(.leading, 3)
                                                            
                                                                
                                                            }

                                                            if let createTime = item.attributes.createdAt{
                                                                Text(" \(calculateTimeDifference(from: createTime))")
                                                                    .font(.system(size: 8))
                                                                    .foregroundColor(.gray)
                                                            }
                                                            
                                                            if let editedTime = item.attributes.editedAt{
                                                                Text("Edited")
                                                                    .font(.system(size: 8))
                                                                    .foregroundColor(.gray)
                                                                    .italic()
                                                            }
                                                            
                                                            Spacer()
                                                            
                                                            if item.id == String(getBestAnswerID()) {
                                                                Image(systemName: "checkmark.circle")
                                                                    .font(.system(size: 15))
                                                                    .fontWeight(.bold)
                                                                    .foregroundColor(.green)
                                                            }
                                                        }
                                                        
                                                        if let userid = item.relationships?.user?.data.id {
                                                           let userInfo = getUserInfo(userid, in: usersArray)
                                                           
                                                            let userLevel = getLevel(user: userInfo.user)
                                                            
                                                            Text(String(format: "Lv.%3d", userLevel))
                                                                .shimmering(active: isUserVip(identifier: userInfo.username ?? ""), animation: Shimmer.defaultAnimation, gradient: Gradient(colors: [
                                                                    Color(hex: "ffffff").opacity(0.8),
                                                                    Color(hex: "182848"),
                                                                    Color(hex: "ffffff").opacity(0.8)
                                                                ]), bandSize: 0.5)
                                                                .bold()
                                                                .foregroundColor(Color.white)
                                                                .font(.system(size: 10))
                                                                .padding()
                                                                .background(Color(hex: "6168d0").opacity(0.8))
                                                                .frame(height: 16)
                                                                .cornerRadius(8)
                                                                .offset(x: 1.2, y: -4)
                                                            
                                                        }
                                                    }
                                                }
                                                
                                                CommentDisplayView(copiedText: $copiedText, contentHTML: item.attributes.contentHTML)
                                            }
                                        }
                                        
                                        LikesAndMentionedButton(postId: item.id,
                                                                likesCount: item.attributes.likesCount,
                                                                mentionedByCount: item.attributes.mentionedByCount,
                                                                isUserLiked : ifContainsUserLike(postItem: item)
                                        )
                                        .padding(.bottom, 5)
                                        .padding(.top, 5)
                                        
                                        Divider()
                                    }
                                    .opacity(isHidden ? 0.3 : 1)
                                    .listRowBackground(item.id == String(getBestAnswerID()) ? Color(hex: "00FFFF").opacity(0.2) : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                                    .listRowSeparator(.hidden)
                                }
                                
                                if !loadMoreButtonDisabled(){
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            if selectedSortOption == NSLocalizedString("default_sort_option", comment: ""){
                                                currentPage += 1
                                                isLoading = true
                                            }else if selectedSortOption == NSLocalizedString("latest_sort_option", comment: ""){
                                                if currentPage > 1 {
                                                    currentPage -= 1
                                                }
                                            }

                                            Task {
                                                fetchDetail(postID: postID){success in
                                                    print("fetchDetail...(in load more button)")
                                                }
                                                isLoading = false
                                            }
                                        }) {
                                            HStack{
                                                Spacer()
                                                Text("Load More")
                                                    .bold()
                                                Spacer()
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 350, height: 50)
                                        .background(Color("FlarumTheme"))
                                        .cornerRadius(10)
                                        .disabled(loadMoreButtonDisabled())
                                        .listRowSeparator(.hidden)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .onChange(of: selectedSortOption) { newValue in
                                if selectedSortOption == NSLocalizedString("default_sort_option", comment: "") {
                                    currentPage = 1
                                } else if selectedSortOption == NSLocalizedString("latest_sort_option", comment: "") {
                                    if commentCount % 20 == 0 {
                                        currentPage = commentCount / 20
                                    } else {
                                        currentPage = (commentCount / 20) + 1
                                    }
                                }
                                
                                Task {
                                    clearData()
                                    await fetchTagsData()
                                    if !isLoading {
                                        isLoading = true
                                        fetchDetail(postID: postID){success in
                                            print("fetchDetail... (on chage of seleted option)")
                                        }
                                        isLoading = false
                                    }
                                }
                            }
                        }
                    }
                    .overlay(
                        CopiedTextView(copiedText: $copiedText)
                    )
//                    .searchable(text: $searchTerm, prompt: "Search")
                    
                    Button {
                        showingPostingArea.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color("FlarumTheme").gradient)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 4)

                    }
                    .padding()
                    .padding(.bottom, 50)
//                    .padding(.trailing, 10)
                }
            }

            
        }
        .navigationDestination(for: [Datum6].self){tagsArray in
            List{
                ForEach(tagsArray, id: \.id){tag in
                    NavigationLink(value: tag){
                        HStack {
                            TagElement(tag: tag, fontSize: 20)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            Spacer()
                        }
                    }
                }
            }
            .navigationDestination(for: Datum6.self){tag in
                TagDetail(selectedTag: tag)
            }
        }
        .navigationDestination(for: Included5.self) { item in
            if let userIdString = item.relationships?.user?.data.id, let userId = Int(userIdString) {
                let userInfo = getUserInfo(userIdString, in: self.usersArray)
                let isVIP = isUserVip(identifier: userIdString)
                LinksProfileView(userId: userId, isVIP: isVIP, Exp: getExp(user: userInfo.user))
            }
        }

        .navigationDestination(for: Datum6.self){data in
            TagDetail(selectedTag: data)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(postTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Menu {
                Section(NSLocalizedString("sorted_by_text", comment: "")){
                    Button {
                        //选择默认的逻辑
                        selectedSortOption = NSLocalizedString("default_sort_option", comment: "")
                    } label: {
                        Label(NSLocalizedString("default_sort_option", comment: ""), systemImage: "seal")
                    }
                
                    Button {
                        //选择最新的逻辑
                        selectedSortOption = NSLocalizedString("latest_sort_option", comment: "")
                    } label: {
                        Label(NSLocalizedString("latest_sort_option", comment: ""), systemImage: "timer")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .padding(.trailing)
            }
        )
        .sheet(isPresented: $showingPostingArea) {
            newReply(postID: self.postID)
                .presentationDetents([.height(250)])
        }
        .onChange(of: appsettings.refreshReplyView) { _ in
            clearData()
            isLoading = true
            Task {
                fetchDetail(postID: postID){success in
                    print("fetchDetail...(fresh the page after posting)")
                }
                isLoading = false
            }
        }
        .refreshable {
            Task {
                clearData()
                if selectedSortOption == NSLocalizedString("default_sort_option", comment: ""){
                    currentPage = 1
                }else{
                    if commentCount % 20 == 0 {
                        currentPage = commentCount / 20
                    } else {
                        currentPage = (commentCount / 20) + 1
                    }
                }
                
                isLoading = true
                fetchDetail(postID: postID){success in
                    print("fetchDetail... (in refreshable)")
                }
                isLoading = false
            }
        }
        .task {
            await fetchTagsData()
            
            if !isLoading {
                isLoading = true
                clearData()
                fetchDetail(postID: postID){success in
                    print("fetchDetail...(in task)")
                }
                isLoading = false
            }
        }
    }
    
    private func isPostHidden(post : Included5) -> Bool{
        var isHidden = false
        if let hidden = post.attributes.isHidden{
            switch hidden{
            case .bool(let bool):
                isHidden = bool
            case .integer(_):
                isHidden = false
            }
            return isHidden
        }
        return false
    }
    
    private func ifContainsUserLike(postItem: Included5) -> Bool {
        let userId = String(appsettings.userId)
        
        if let likesData = postItem.relationships?.likes?.data{
            for likeItem in likesData {
                if likeItem.id == userId {
                    return true
                }
            }
        }
        return false
    }
 
    private func fetchDetail(postID: String, completion: @escaping (Bool) -> Void) {
        // clearData()
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/discussions/\(postID)?page[number]=\(currentPage)") else {
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
                print("current page: \(currentPage)")
                print("fetching postID: \(postID)")

                if let decodedResponse = try? JSONDecoder().decode(PostDataWithTag.self, from: data) {
                    print("Successfully decoding use PostDataWithTag.self")
                    include = decodedResponse.included
                    postsData = decodedResponse.data
                    
                    if let tagData = decodedResponse.data.relationships.tags?.data {
                        for tag in tagData {
                            tagsIdInPostDetail.append(tag.id)
                            print("current post has tag with id: \(tag.id)")
                        }
                    }
                    processIncludedTagsArray(include)
                } else {
                    print("Decoding to PostData Failed!")
                }
            }
            
            // 请求成功后调用回调
            completion(true)
            
        }.resume()
    }

    private func processIncludedTagsArray(_ includedArray: [Included5]) {
        print("process Comment List Array...")
        //默认发帖顺序排序
        if selectedSortOption == NSLocalizedString("default_sort_option", comment: ""){
            for included in includedArray {
                switch included.type {
                case "posts":
                    if let contentType = included.attributes.contentType, contentType == "comment" {
                        self.postsArray.append(included)
                    }
                case "users":
                    self.usersArray.append(included)
                case "polls":
                    if !self.polls.contains(included){
                        self.polls.append(included)
                    }
                case "poll_options":
                    self.pollOptions.append(included)
                default:
                    break
                }
            }
        }
        
        //按最新发帖排序
        if selectedSortOption == NSLocalizedString("latest_sort_option", comment: ""){
            for included in includedArray.reversed() {
                switch included.type {
                case "posts":
                    if let contentType = included.attributes.contentType, contentType == "comment" {
                        var tempArray: [Included5] = []
                        tempArray.append(included)
                        self.postsArray.append(contentsOf: tempArray.reversed())
                    }

                case "users":
                    self.usersArray.append(included)
                case "polls":
                    if !self.polls.contains(included){
                        self.polls.append(included)
                    }
                case "poll_options":
                    self.pollOptions.append(included)
                default:
                    break
                }
            }
        }
    }
    
    private func getUserInfo(_ userid: String, in array: [Included5]) -> (avatarURL: String?, user: Included5?, displayName: String?, username: String?) {
        if let item = array.first(where: { $0.id == userid }) {
            return (item.attributes.avatarURL, item, item.attributes.displayName, item.attributes.username)
        }
        return (nil, nil, nil, nil)
    }
    
    private func isUserVip(identifier: String) -> Bool {
        //judge by username
        if appsettings.vipUsernames.contains(identifier) {
            return true
        } else {
            //judge by userId
            let userInfo = getUserInfo(identifier, in: self.usersArray)
            let username = userInfo.username ?? "Invalid Username"
            return appsettings.vipUsernames.contains(username)
        }
    }

    private func loadMoreButtonDisabled() -> Bool {
        if selectedSortOption == NSLocalizedString("default_sort_option", comment: "") {
            return self.commentCount <= 20 || currentPage * 20 >= self.commentCount || isLoading || currentPage == 0
        } else {
            return isLoading || currentPage == 1
        }
    }
   
    private func clearData() {
        polls = []
        pollOptions = []
        postsArray = []
        usersArray = []
        include = []
    }
    
    private func fetchTagsData() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/tags") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(TagsData.self, from: data) {
                self.fetchedTags = decodedResponse.data
                print("successfully decode tags data in postDetail View")
            }
        } catch {
            print("Invalid Tags Data!", error)
        }
    }
        
    func findPollOptionsAndVoteCount(poll: Included5) -> [String: Int] {
        var pollInfo: [String: Int] = [:]

        for option in poll.relationships?.options?.data ?? [] {
            if let matchingOptionInfo = pollOptions.first(where: { $0.id == option.id }) {
                if let answer = matchingOptionInfo.attributes.answer {
                    let voteCount = matchingOptionInfo.attributes.voteCount ?? 0
                    pollInfo[answer] = voteCount
                }
            }
        }
        return pollInfo
    }

    func findAnswerWithId() -> [String: String] {
        var answerWithId: [String: String] = [:]

        for option in pollOptions {
            if let answer = option.attributes.answer {
                answerWithId[answer] = option.id
            }
        }
        
        return answerWithId
    }
    
    private func getBestAnswerID() -> Int{
        if let ID = postsData?.attributes.hasBestAnswer{
            if ID != 0{
                return ID
            }
        }
        return -1
    }
}

struct CopiedTextView: View {
    @Binding var copiedText: String?
    
    var body: some View {
        ZStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 50, height: 50) // 调整图标大小
                .foregroundColor(Color.green)
                .animation(.easeInOut, value: copiedText)
        }
        .opacity(copiedText != nil ? 1 : 0)
        .animation(.easeInOut, value: copiedText)
    }
}

