//
//  PostDetial.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/30.
//

import SwiftUI

struct fastPostDetailView: View {
    let postTitle: String
    let postID: String
    let commentCount: Int
    
    var sortOption = ["Default", "Latest"]
    @State private var selectedSortOption = "Default"
    
    @State private var currentPage = 1
    @State private var isLoading = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appsettings: AppSettings
    @State private var showingPostingArea = false
    @State private var isLiked = false
    @State private var isReplied = false
    @State private var includes = [Included4]()
    @State var postsArray: [Included4] = []
    @State var usersArray: [Included4] = []
    @State private var includesTags = [Included5]()
    @State var postsArrayTags: [Included5] = []
    @State var usersArrayTags: [Included5] = []
    @State private var searchTerm = ""
    @State private var fetchedTags = [Datum6]()
    @State private var showedTags = [Datum6]()
    @State var tagsIdInPostDetail: [String] = []
    
    var filteredPostsArray: [Included4] {
        var filteredItems: [Included4] = []
        var filteredByContent: [Included4] = []
        var filteredByDisplayName: [Included4] = []
        
        guard !searchTerm.isEmpty else { return postsArray }
        
        for item in postsArray {
            if let content = item.attributes.contentHTML {
                if content.htmlConvertedWithoutUrl.localizedCaseInsensitiveContains(searchTerm) {
                    filteredByContent.append(item)
                }
            }
            
            if let userid = item.relationships?.user?.data.id {
                if let displayName = findDisplayName(userid, in: usersArray) {
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
    
    var body: some View {
        VStack {
            if includes.isEmpty && includesTags.isEmpty {
                HStack {
                    Text("Loading...").foregroundStyle(.secondary)
                    ProgressView()
                }
            } else {
                if !tagsIdInPostDetail.isEmpty {
                    HStack {
                        ForEach(fetchedTags, id: \.id) { tag in
                            if tagsIdInPostDetail.contains(tag.id) {
                                NavigationLink(value: tag){
                                    TagElement(tag: tag, fontSize: 15)
                                }
                            }
                        }
                    }
                    .frame(width: 350, height: 45)
                    .background((colorScheme == .dark ? Color(hex: "0D1117") : Color(hex: "f0f0f5")))
                    .cornerRadius(10)
                    .opacity(0.9)
                }
            }
            
            Picker(
                selection : $selectedSortOption,
                label: Text("Picker"),
                content:{
                    ForEach(sortOption.indices){index in
                        Text(sortOption[index]).tag(sortOption[index])
                    }
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .animation(.easeInOut(duration: 1), value: sortOption)
                .padding(.top, 5)
            
            if selectedSortOption == "Default"{
                if (!postsArray.isEmpty && postsArrayTags.isEmpty){
                    // MARK: - Posts Without tags
                    List(filteredPostsArray, id: \.id){item in
                        VStack {
                            NavigationLink(value: item){
                                HStack {
                                    VStack{
                                        if let userid = item.relationships?.user?.data.id{
                                            if let avatarURL = findImgUrl(userid, in: usersArray){
                                                asyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                                                    .padding(.top, 10)
                                            }else{
                                                CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                    .opacity(0.3)
                                                    .padding(.top, 10)
                                            }
                                        }
                                        Spacer()
                                    }
                                    VStack {
                                        HStack {
                                            if let userid = item.relationships?.user?.data.id{
                                                if let displayName = findDisplayName(userid, in: usersArray){
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
                                        }
                                        
                                        HStack {
                                            if let content = item.attributes.contentHTML{
                                                Text(content.htmlConvertedWithoutUrl)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                            }else{
                                                Text("unsupported")
                                                    .foregroundColor(.gray)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 20))
                                                    .opacity(0.5)
                                            }
                                            Spacer()
                                        }
                                        if let includeImgReply = item.attributes.contentHTML{
                                            if let imageUrls = extractImageURLs(from: includeImgReply){
                                                ForEach(imageUrls, id: \.self) { url in
                                                    AsyncImage(url: URL(string: url)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 215)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 3)
                                                            .overlay(Rectangle()
                                                                .stroke(.white, lineWidth: 1)
                                                                .cornerRadius(10))
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            LikesAndCommentButton()
                                .padding(.bottom, 5)
                                .padding(.top, 5)
                            Divider()
                        }
                        .listRowSeparator(.hidden)
                    }
                    .searchable(text: $searchTerm, prompt: "Search")
                }else{
                    // MARK: - Posts With tags
                    List(filteredPostsArrayTags, id: \.id){item in
                        VStack {
                            NavigationLink(value: item){
                                HStack {
                                    VStack{
                                        if let userid = item.relationships?.user?.data.id{
                                            if let avatarURL = findImgUrl(userid, in: usersArrayTags){
                                                asyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                                                    .padding(.top, 10)
                                            }else{
                                                CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                    .opacity(0.3)
                                                    .padding(.top, 10)
                                            }
                                        }
                                        Spacer()
                                    }
                                    VStack {
                                        HStack {
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
                                        }
                                        
                                        HStack {
                                            if let content = item.attributes.contentHTML{
                                                Text(content.htmlConvertedWithoutUrl)
                                                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 15))
                                            }else{
                                                Text("unsupported")
                                                    .foregroundColor(.gray)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 20))
                                                    .opacity(0.5)
                                            }
                                            Spacer()
                                        }
                                        if let includeImgReply = item.attributes.contentHTML{
                                            if let imageUrls = extractImageURLs(from: includeImgReply){
                                                ForEach(imageUrls, id: \.self) { url in
                                                    AsyncImage(url: URL(string: url)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 215)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 3)
                                                            .overlay(Rectangle()
                                                                .stroke(.white, lineWidth: 1)
                                                                .cornerRadius(10))
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            LikesAndCommentButton()
                                .padding(.bottom, 5)
                                .padding(.top, 5)
                            Divider()
                        }
                        .listRowSeparator(.hidden)
                    }
                    .searchable(text: $searchTerm, prompt: "Search")
                }
            }else if selectedSortOption == "Latest"{
                if (!postsArray.isEmpty && postsArrayTags.isEmpty){
                    // MARK: - Posts Without tags
                    List(filteredPostsArray.reversed(), id: \.id){item in
                        VStack {
                            NavigationLink(value: item){
                                HStack {
                                    VStack{
                                        if let userid = item.relationships?.user?.data.id{
                                            if let avatarURL = findImgUrl(userid, in: usersArray){
                                                asyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                                                    .padding(.top, 10)
                                            }else{
                                                CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                    .opacity(0.3)
                                                    .padding(.top, 10)
                                            }
                                        }
                                        Spacer()
                                    }
                                    VStack {
                                        HStack {
                                            if let userid = item.relationships?.user?.data.id{
                                                if let displayName = findDisplayName(userid, in: usersArray){
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
                                        }
                                        
                                        HStack {
                                            if let content = item.attributes.contentHTML{
                                                Text(content.htmlConvertedWithoutUrl)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                            }else{
                                                Text("unsupported")
                                                    .foregroundColor(.gray)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 20))
                                                    .opacity(0.5)
                                            }
                                            Spacer()
                                        }
                                        if let includeImgReply = item.attributes.contentHTML{
                                            if let imageUrls = extractImageURLs(from: includeImgReply){
                                                ForEach(imageUrls, id: \.self) { url in
                                                    AsyncImage(url: URL(string: url)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 215)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 3)
                                                            .overlay(Rectangle()
                                                                .stroke(.white, lineWidth: 1)
                                                                .cornerRadius(10))
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            LikesAndCommentButton()
                                .padding(.bottom, 5)
                                .padding(.top, 5)
                            Divider()
                        }
                        .listRowSeparator(.hidden)
                    }
                    .searchable(text: $searchTerm, prompt: "Search")
                }else{
                    // MARK: - Posts With tags
                    List(filteredPostsArrayTags.reversed(), id: \.id){item in
                        VStack {
                            NavigationLink(value: item){
                                HStack {
                                    VStack{
                                        if let userid = item.relationships?.user?.data.id{
                                            if let avatarURL = findImgUrl(userid, in: usersArrayTags){
                                                asyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                                                    .padding(.top, 10)
                                            }else{
                                                CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                    .opacity(0.3)
                                                    .padding(.top, 10)
                                            }
                                        }
                                        Spacer()
                                    }
                                    VStack {
                                        HStack {
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
                                        }
                                        
                                        HStack {
                                            if let content = item.attributes.contentHTML{
                                                Text(content.htmlConvertedWithoutUrl)
                                                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 15))
                                            }else{
                                                Text("unsupported")
                                                    .foregroundColor(.gray)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 20))
                                                    .opacity(0.5)
                                            }
                                            Spacer()
                                        }
                                        if let includeImgReply = item.attributes.contentHTML{
                                            if let imageUrls = extractImageURLs(from: includeImgReply){
                                                ForEach(imageUrls, id: \.self) { url in
                                                    AsyncImage(url: URL(string: url)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 215)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 3)
                                                            .overlay(Rectangle()
                                                                .stroke(.white, lineWidth: 1)
                                                                .cornerRadius(10))
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            LikesAndCommentButton()
                                .padding(.bottom, 5)
                                .padding(.top, 5)
                            Divider()
                        }
                        .listRowSeparator(.hidden)
                    }
                    .searchable(text: $searchTerm, prompt: "Search")
                }
            }
            

            HStack {
                Button(action: {
                    if selectedSortOption == "Default"{
                        currentPage += 1
                        isLoading = true
                    }else if selectedSortOption == "Latest"{
                        if currentPage > 1 {
                            currentPage -= 1
                        }
                    }

                    Task {
                        await fetchDetail(postID: postID)
                        isLoading = false
                    }
                }) {
                    HStack{
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                            .font(.system(size: 17))
                            .padding(.top, 1)
                        Text("Load More")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14))
                    }
                }
                .disabled(loadMoreButtonDisabled())
            }
            .frame(width: (loadMoreButtonDisabled()) ? 0 : 100, height: (loadMoreButtonDisabled()) ? 0 : 23)
            .background((colorScheme == .dark ? Color(hex: "0D1117") : Color(hex: "f0f0f5")))
            .cornerRadius(10)
            .opacity((loadMoreButtonDisabled()) ? 0 : 0.9)
            .padding(.bottom)
            .onChange(of: selectedSortOption) { newValue in
                if newValue == "Default" {
                    currentPage = 1
                } else if newValue == "Latest" {
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
                        await fetchDetail(postID: postID)
                        isLoading = false
                    }
                }
            }

            
            Spacer()
        }
        .navigationDestination(for: Included4.self){item in
            if let userIdString = item.relationships?.user?.data.id, let userId = Int(userIdString) {
                LinksProfileView(userId: userId)
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
        .toolbar {
            Button {
                showingPostingArea.toggle()
            } label: {
                Label("New Reply", systemImage: "plus.message.fill")
            }
        }
        .sheet(isPresented: $showingPostingArea) {
            newReply(postID: self.postID)
                .presentationDetents([.height(250)])
        }
        .onReceive(appsettings.$refreshReplyView) { _ in
            Task {
                clearData()
                isLoading = true
                await fetchDetail(postID: postID)
                isLoading = false
            }
        }
        .refreshable {
            Task {
                clearData()
                if selectedSortOption == "Default"{
                    currentPage = 1
                }else{
                    if commentCount % 20 == 0 {
                        currentPage = commentCount / 20
                    } else {
                        currentPage = (commentCount / 20) + 1
                    }
                }
                
                isLoading = true
                await fetchDetail(postID: postID)
                isLoading = false
            }
        }
        .task {
            await fetchTagsData()
            
            if !isLoading {
                isLoading = true
                clearData()
                await fetchDetail(postID: postID)
                isLoading = false
            }
        }
    }
 
    private func fetchDetail(postID: String) async {
//        clearData()
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/discussions/\(postID)?page[number]=\(currentPage)") else{
                print("Invalid URL")
            return
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(PostData.self, from: data){
                includes = decodedResponse.included
                
                processIncludedArray(includes)
                print("Successfully decoding use PostData.self")
            }else{
                print("Decoding to PostData.self Failed, Post has tags!")
                
                if let decodedResponse = try? JSONDecoder().decode(PostDataWithTag.self, from: data){
                    print("Successfully decoding use PostDataWithTag.self")
                    includesTags = decodedResponse.included
                    
                    if let tagData = decodedResponse.data.relationships.tags?.data {
                        for tag in tagData {
                            tagsIdInPostDetail.append(tag.id)
                            print("current post has tag with id: \(tag.id)")
                        }
                    }
                    
                    processIncludedTagsArray(includesTags)
                }else{
                    print("Decoding to PostData Failed!")
                }
            }

        } catch {
            print("Invalid post data!" ,error)
        }
    }
    
    private func processIncludedArray(_ includedArray: [Included4]) {
        for included in includedArray {
            switch included.type {
            case "posts":
                if let contentType = included.attributes.contentType, contentType == "comment" {
                    self.postsArray.append(included)
                }
            case "users":
                self.usersArray.append(included)
            default:
                break
            }
        }
    }
 
    private func processIncludedTagsArray(_ includedArray: [Included5]) {
        for included in includedArray {
            switch included.type {
            case "posts":
                if let contentType = included.attributes.contentType, contentType == "comment" {
                    self.postsArrayTags.append(included)
                }
            case "users":
                self.usersArrayTags.append(included)
            default:
                break
            }
        }
    }

    private func findDisplayName(_ userid: String, in array: [Included4]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.displayName
        }
        return nil
    }
    
    private func findImgUrl(_ userid: String, in array: [Included4]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.avatarURL
        }
        return nil
    }

    private func findDisplayName(_ userid: String, in array: [Included5]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.displayName
        }
        return nil
    }
    
    private func findImgUrl(_ userid: String, in array: [Included5]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            return item.attributes.avatarURL
        }
        return nil
    }
    
    private func loadMoreButtonDisabled() -> Bool{
        return self.commentCount <= 20 || currentPage * 20 >= self.commentCount || isLoading || currentPage == 0
    }
    
    private func clearData() {
        includes = []
        postsArray = []
        usersArray = []
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
}

//#Preview {
//    fastPostDetailView(postTitle: "Test", postID: "1")
//}

