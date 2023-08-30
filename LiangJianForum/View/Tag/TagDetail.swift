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
                ProgressView()
            } else {
                if hasPrevPage || hasNextPage {
                    HStack{
                        Button(action: {
                            if currentPageOffset >= 20 {
                                currentPageOffset -= 20
                            }
                            isLoading = true
                            Task {
                                await fetchTagsDetailPosts()
                                isLoading = false
                            }
                        }) {
                            HStack{
                                Image(systemName: "chevron.left")
                                    .foregroundColor(hasPrevPage ? .blue : .secondary)
                                    .font(.system(size: 20))
                                    .padding(.top, 1)
                                Text("Prev")
                                    .foregroundStyle(hasPrevPage ? .blue : .secondary)
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(.leading)
                        .disabled(!hasPrevPage)
                        
                        Spacer()
                        
                        Button(action: {
                            isLoading = true
                            currentPageOffset = 0
                            isLoading = false
                            Task {
                                await fetchTagsDetailPosts()
                                isLoading = false
                            }
                        }) {
                            HStack{
                                Text("First Page")
                                    .foregroundStyle(hasPrevPage ? .blue : .secondary)
                                    .font(.system(size: 14))
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            currentPageOffset += 20
                            isLoading = true
                            Task {
                                await fetchTagsDetailPosts()
                                isLoading = false
                            }
                        }) {
                            HStack{
                                Text("Next")
                                    .foregroundStyle(hasNextPage ? .blue : .secondary)
                                    .font(.system(size: 14))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(hasNextPage ? .blue : .secondary)
                                    .font(.system(size: 20))
                                    .padding(.top, 1)
                            }
                        }
                        .padding(.trailing)
                        .disabled(!hasNextPage)
                    }.padding(.top)
                }

                ScrollViewReader { proxy in
                    List {
                        Section{
                            ForEach(filteredDiscussionData, id: \.id) { item in
                                if item.attributes.lastPostedAt != nil{
                                    HStack {
                                        VStack {
                                            NavigationLink(value: item){
                                                //MARK: 头像及标题
                                                HStack{
                                                    if let user = findUser(with: item.relationships.user.data.id) {
                                                        
                                                        if let avatarURL = user.attributes.avatarUrl {
                                                            asyncImage(url: URL(string: avatarURL), frameSize: 40, lineWidth: 1, shadow: 3)
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
                                                
                                                FavoriteButton()
                                                
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
                    .searchable(text: $searchTerm, prompt: "Search")
                    .toolbar {
                        Button {
                            showingPostingArea.toggle()
                        } label: {
                            Image(systemName: "plus.bubble.fill")
                        }
                    }
                    .sheet(isPresented: $showingPostingArea) {
                        newPostView().environmentObject(appsettings)
                            .presentationDetents([.height(480)])
                    }
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationTitle(self.selectedTag.attributes.name)
                    .toolbarBackground(selectedTag.attributes.color.isEmpty ? Color.gray.opacity(0.8) : Color(hex: removeFirstCharacter(from: selectedTag.attributes.color)).opacity(0.8), for: .automatic)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: Datum.self){item in
                        fastPostDetailView(postTitle: item.attributes.title, postID: item.id, commentCount: item.attributes.commentCount).environmentObject(appsettings)
                    }
                }
            }
        }
        .refreshable {
            isLoading = true
            await fetchTagsDetailPosts()
            isLoading = false
        }
        .task {
            await fetchTagsDetailPosts()
        }
        .onAppear {
            Task {
                await fetchTagsDetailPosts()
            }
        }

    }
    
    private func checkIfHasBestAnswer(dataIn: HasBestAnswer) -> Bool {
        var hasBestAnswer = false
        
        switch dataIn {
        case .integer:
            hasBestAnswer = true
        default:
            hasBestAnswer = false
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
    
    private func fetchTagsDetailPosts() async {
        
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?include=user%2ClastPostedUser%2Ctags%2Ctags.parent%2CfirstPost&filter%5Btag%5D=\(selectedTag.attributes.slug)&sort=&page%5Boffset%5D=\(currentPageOffset)") else{
                print("Invalid URL")
            return
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(Discussion.self, from: data){
                discussionData = decodedResponse.data
                discussionIncluded = decodedResponse.included
                discussionLinksFirst = decodedResponse.links.first
                
                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }
                
                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }
                
                print("successfully decode tags detail data")
                print("current tags api url: \(discussionLinksFirst)")
                print("current page offset: \(currentPageOffset)")
                print("has next page: \(hasNextPage)")
                print("has prev page: \(hasPrevPage)")
            }

        } catch {
            print("Invalid tags detail data!" ,error)
        }
    }
}

