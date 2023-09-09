//
//  PostDetial.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/30.
//

import SwiftUI

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
    @State private var includesTags = [Included5]()
    @State var postsArrayTags: [Included5] = []
    @State var usersArrayTags: [Included5] = []
    @State var polls: [Included5] = []
    @State var pollOptions: [Included5] = []
    @State private var searchTerm = ""
    @State private var fetchedTags = [Datum6]()
    @State private var showedTags = [Datum6]()
    @State var tagsIdInPostDetail: [String] = []
    @State private var copiedText: String?
    @State private var postsWithTagData : DataClass5?

    var filteredPostsArrayTags: [Included5] {
        var filteredItems: [Included5] = []
        var filteredByContent: [Included5] = []
        var filteredByDisplayName: [Included5] = []
        
        guard !searchTerm.isEmpty else { return postsArrayTags }
        
        for item in postsArrayTags {
            if let content = item.attributes.contentHTML {
                if content.htmlConvertedWithoutUrl.localizedCaseInsensitiveContains(searchTerm) {
                    filteredByContent.append(item)
                }
            }
            
            if let userid = item.relationships?.user?.data.id {
                if let displayName = findDisplayName(userid, in: usersArrayTags) {
                    if displayName.localizedCaseInsensitiveContains(searchTerm) {
                        filteredByDisplayName.append(item)
                    }
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
            if includesTags.isEmpty {
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
                        if (postsArrayTags.isEmpty){
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
                            }     
                            
                            Section("帖子回复"){
                                // MARK: - Post list
                                ForEach(filteredPostsArrayTags, id: \.id){item in
                                    VStack {
                                        HStack {
                                            VStack {
                                                NavigationLink(value: item){
                                                    HStack {
                                                        if let userid = item.relationships?.user?.data.id{
                                                            if let avatarURL = findImgUrl(userid, in: usersArrayTags), let username = findUsername(userid, in: usersArrayTags){
                                                                if isUserVip(username: username){
                                                                    AvatarAsyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1.2, shadow: 3, strokeColor : Color(hex: "FFD700"))
                                                                        .padding(.top, 10)
                                                                        .padding(.leading, 6)
                                                                }else{
                                                                    AvatarAsyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                                                                        .padding(.top, 10)
                                                                        .padding(.leading, 6)
                                                                }
                                                            }else{
                                                                CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                                    .opacity(0.3)
                                                                    .padding(.top, 10)
                                                                    .padding(.leading, 6)
                                                            }
                                                        }
                                                        
                                                        if let userid = item.relationships?.user?.data.id{
                                                            if let displayName = findDisplayName(userid, in: usersArrayTags){
                                                                Text(displayName)
                                                                    .font(.system(size: 12))
                                                                    .bold()
                                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                                
                                                                    .padding(.leading, 3)
                                                            }
                                                        }else{
                                                            ProgressView()
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
                                                            Text("Best Answer")
                                                                .font(.system(size: 10))
                                                                .fontWeight(.bold)
                                                                .foregroundColor(.green)
                                                                .padding(.trailing)
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
                                    .background(item.id == String(getBestAnswerID()) ? Color.green.opacity(0.2) : Color.clear)
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
                                        .background(Color(hex: "565dd9"))
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
                        Image(systemName: "plus.message.fill")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color(hex: "565dd9").gradient)
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
        .navigationDestination(for: Included5.self){item in
            if let userIdString = item.relationships?.user?.data.id, let userId = Int(userIdString) {
                LinksProfileView(userId: userId)
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
            Task {
                clearData()
                isLoading = true
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
                
                print("Decoding to PostData.self Failed, Post has tags!")
                
                if let decodedResponse = try? JSONDecoder().decode(PostDataWithTag.self, from: data) {
                    print("Successfully decoding use PostDataWithTag.self")
                    includesTags = decodedResponse.included
                    postsWithTagData = decodedResponse.data
                    
                    if let tagData = decodedResponse.data.relationships.tags?.data {
                        for tag in tagData {
                            tagsIdInPostDetail.append(tag.id)
                            print("current post has tag with id: \(tag.id)")
                        }
                    }
                    processIncludedTagsArray(includesTags)
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
                        self.postsArrayTags.append(included)
                    }
                case "users":
                    self.usersArrayTags.append(included)
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
                        self.postsArrayTags.append(contentsOf: tempArray.reversed())
                    }

                case "users":
                    self.usersArrayTags.append(included)
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

    private func findDisplayName(_ userid: String, in array: [Included5]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.displayName
        }
        return nil
    }
    
    private func findUsername(_ userid: String, in array: [Included5]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.username
        }
        return nil
    }
    
    private func findImgUrl(_ userid: String, in array: [Included5]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.avatarURL
        }
        return nil
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
        postsArrayTags = []
        usersArrayTags = []
        includesTags = []
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
        if let ID = postsWithTagData?.attributes.hasBestAnswer{
            if ID != 0{
                return ID
            }
        }
        return -1
    }
    
    private func isUserVip(username: String) -> Bool{
        return appsettings.vipUsernames.contains(username)
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

