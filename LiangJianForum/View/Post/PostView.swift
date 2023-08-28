//
//  PostViewTest.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/29.
//

import SwiftUI

struct PostView: View {
    @State private var currentPage = 1
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
    @State private var isHeaderSlideViewEnabled = false
    @State private var isSortingMenuVisible = false
    @State private var selectedSortingOption = NSLocalizedString("default_sort", comment: "")
    
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
                NavigationStack{
                    ScrollViewReader{ proxy in
                        PaginationView(hasPrevPage: hasPrevPage, hasNextPage: hasNextPage, currentPage: $currentPage, isLoading: $isLoading, fetchDiscussion: fetchDiscussion)
                        
                        List {
                            // MARK: - if Flarum has HeaderSlide Plugin installed with api endpoint \(appsettings.FlarumUrl)/api/header-slideshow/list
                            if isHeaderSlideViewEnabled{
                                Section{
                                    HeaderSlideView()
                                        .frame(height: 100)
                                }
                                .id("Top")
                                .listRowInsets(EdgeInsets())
                            }

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
                                                    
                                                    if item.attributes.isSticky{
                                                        Spacer()
                                                        
                                                        Image(systemName: "flag.fill")
                                                            .font(.system(size: 15))
                                                            .padding(.leading)
                                                            .foregroundColor(.red)
                                                            .opacity(0.8)
                                                    }
                                                    
                                                    FavoriteButton()
                                                    
                                                }
                                                .padding(.top, 10)
                                                .padding(.bottom, 5)

                                                Divider()
                                            }
                                        }
                                        .listRowSeparator(.hidden)
                                    }
                                }
                            }
                            .id("TopWithoutSlide")
                        }
//                        .listStyle(.inset)
                        .onChange(of: currentPage) { _ in
                            // Whenever currentPage changes, scroll to the top of the list
                            withAnimation {
                                isLoading = true
                                if isHeaderSlideViewEnabled{
                                    proxy.scrollTo("Top", anchor: .top)
                                }else{
                                    proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                }
                                
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
                                .presentationDetents([.height(560)])
                        }
                        .navigationTitle("All Discussions")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationDestination(for: Datum.self){item in
                            fastPostDetailView(postTitle: item.attributes.title, postID: item.id, commentCount: item.attributes.commentCount).environmentObject(appsettings)
                        }
                        .navigationBarItems(leading:
                            Menu {
                            
                            Section(NSLocalizedString("sorted_by_text", comment: "")){
                                Button {
                                    //选择默认的逻辑
                                    if isHeaderSlideViewEnabled{
                                        proxy.scrollTo("Top", anchor: .top)
                                    }else{
                                        proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                    }
                                    selectedSortingOption = NSLocalizedString("default_sort", comment: "")
                                } label: {
                                    Label(NSLocalizedString("default_sort", comment: ""), systemImage: "seal")
                                }
                            
                                Button {
                                    //选择最新的逻辑
                                    if isHeaderSlideViewEnabled{
                                        proxy.scrollTo("Top", anchor: .top)
                                    }else{
                                        proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                    }
                                    selectedSortingOption = NSLocalizedString("latest_sort", comment: "")
                                } label: {
                                    Label(NSLocalizedString("latest_sort", comment: ""), systemImage: "timer")
                                }
                            }
                                
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                            }
                        )

                    }
                }
            }
        }
        .refreshable {
            await fetchDiscussion()
        }
        .onReceive(appsettings.$refreshPostView) { _ in
            Task {
                await fetchDiscussion()
            }
        }
        .task {
            await fetchDiscussion()
        }
        .onAppear {
            // Check the URL status and set isHeaderSlideViewEnabled accordingly
            checkURLStatus(urlString: "\(appsettings.FlarumUrl)/api/header-slideshow/list") { success in
                DispatchQueue.main.async {
                    self.isHeaderSlideViewEnabled = success
                }
            }
        }
        .onChange(of: selectedSortingOption){ newValue in
            currentPage = 1
            Task {
                await fetchDiscussion()
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
    
    private func fetchDiscussion() async {
        var url: URL? = nil // 声明url变量并初始化为nil
        
        if selectedSortingOption == NSLocalizedString("default_sort", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)")
        } else if selectedSortingOption == NSLocalizedString("latest_sort", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-createdAt")
        }
        
        // 检查url是否为nil
        guard let url = url else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(Discussion.self, from: data) {
                discussionData = decodedResponse.data
                discussionIncluded = decodedResponse.included
                discussionLinksFirst = decodedResponse.links.first
                
                if decodedResponse.links.next == nil || decodedResponse.links.next == "" {
                    self.hasNextPage = false
                } else {
                    self.hasNextPage = true
                }
                
                if decodedResponse.links.prev != nil && currentPage != 1 {
                    self.hasPrevPage = true
                } else {
                    self.hasPrevPage = false
                }
                
                print("successfully decode discussions data")
                print("current api url: \(discussionLinksFirst)")
                print("current page: \(currentPage)")
                print("has next page: \(hasNextPage)")
                print("has prev page: \(hasPrevPage)")
            }

        } catch {
            print("Invalid Discussions Overview And Title Data!", error)
        }
    }

    
    func checkURLStatus(urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                completion(statusCode == 200)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }
}

//#Preview {
//    PostView()
//}
