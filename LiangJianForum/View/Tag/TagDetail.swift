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
                                                            asyncImage(url: URL(string: avatarURL), frameSize: 70, lineWidth: 1, shadow: 3)
                                                        } else {
                                                            CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 70, lineWidth: 1, shadow: 3)
                                                                .opacity (0.3)
                                                        }
                                                    }
                                                    
                                                    VStack {
                                                        HStack {
                                                            Text(item.attributes.title)
                                                                .font(.system(size: 25))
                                                                .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : Color(hex: "243B55"))
                                                                .bold()
                                                                .fixedSize(horizontal: false, vertical: true)
                                                                .padding(.leading)
                                                            Spacer()
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                            }
                                            
                                            //MARK: 最后更新时间
                                            HStack {
                                                Image(systemName: "clock.fill")
                                                    .foregroundColor(.gray)
                                                
                                                if let lastPostedAt = item.attributes.lastPostedAt {
                                                    Text(calculateTimeDifference(from: lastPostedAt))
                                                        .font(.system(size: 15))
                                                        .foregroundColor(.gray)
                                                } else {
                                                    Text("新帖审核中...")
                                                        .font(.system(size: 15))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.top, 10)
                                            
                                            //MARK: 评论数 阅读数量 收藏
                                            HStack {
                                                Image(systemName: "bubble.middle.bottom.fill")
                                                    .foregroundColor(.gray)
                                                Text("\(item.attributes.commentCount)")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 15))
                                                
                                                if let viewcount = item.attributes.viewCount{
                                                    Image(systemName: "eye.fill")
                                                        .foregroundColor(.gray)
                                                        .padding(.leading)
                                                    Text("\(viewcount)")
                                                        .foregroundColor(.gray)
                                                        .font(.system(size: 15))
                                                }
                                                
                                                Spacer()
                                                
                                                if item.attributes.isSticky{
                                                    Spacer()
                                                    
                                                    Image(systemName: "flag.fill")
                                                        .frame(width: 12, height: 12)
                                                        .padding(.leading)
                                                        .foregroundColor(.red)
                                                        .opacity(0.8)
                                                }
                                                
                                                FavoriteButton()
                                            }
                                            .padding(.top, 10)
                                            Divider()
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .id("TagDetailList")
                        }
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

