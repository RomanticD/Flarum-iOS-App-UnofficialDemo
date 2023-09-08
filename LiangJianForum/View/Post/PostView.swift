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
    @State private var dragAmount : CGPoint?
    @State private var selectedSortingOption = NSLocalizedString("latest_sort_comment", comment: "")
    
    private func findDisplayName(_ userid: String, in array: [Included]) -> String? {
        if let item = array.first(where: { $0.id == userid }) {
            if let displayName = item.attributes.displayName{
                return displayName
            }
        }
        return nil
    }
    
    var shadowColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
   
    var filteredDiscussionData : [Datum] {
        guard !searchTerm.isEmpty else { return discussionData }

        return discussionData
    }

    
    var body: some View {
        GeometryReader{ geometry in
          VStack {
              if discussionData.isEmpty || isLoading{
                  PostViewContentLoader(selectedSortingOption: selectedSortingOption)
              } else {
                  NavigationStack{
                      ScrollViewReader{ proxy in
                          ZStack(alignment: .bottomTrailing) {
                              VStack {
                                  PaginationView(hasPrevPage: hasPrevPage,
                                                 hasNextPage: hasNextPage,
                                                 currentPage: $currentPage,
                                                 isLoading: $isLoading,
                                                 fetchDiscussion: fetchDiscussion,
                                                 fetchUserInfo: nil,
                                                 mode: .page
                                  )
                                  
                                  List {
                                      // MARK: - if Flarum has HeaderSlide Plugin installed with api endpoint \(appsettings.FlarumUrl)/api/header-slideshow/list
                                      if selectedSortingOption != "Search"{
                                          if isHeaderSlideViewEnabled{
                                              Section{
                                                  HeaderSlideView()
                                                      .frame(height: 100)
                                              }
                                              .id("Top")
                                              .listRowInsets(EdgeInsets())
                                          }

                                      }
                                                                            
                                      if selectedSortingOption == "Search"{
                                          Section{
                                              HStack {
                                                  Spacer()
                                                  
                                                  Button(action: {
                                                      discussionData = []
                                                      selectedSortingOption = NSLocalizedString("latest_sort_comment", comment: "")
                                                  }) {
                                                      HStack {
                                                          Text("退出搜索")
                                                              .bold()
                                                      }
                                                  }
                                                  .foregroundColor(.white)
                                                  .frame(width: 350, height: 50)
                                                  .background(Color(hex: "787de1").gradient)
                                                  .cornerRadius(10)
                                                  
                                                  Spacer()
                                              }
                                          }
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
                                  .sheet(isPresented: $showingPostingArea) {
                                      newPostView().environmentObject(appsettings)
                                          .presentationDetents([.medium, .large])
                                  }
                                  .navigationTitle(selectedSortingOption)
                                  .navigationBarTitleDisplayMode(.inline)
                                  .navigationDestination(for: Datum.self){item in
                                      PostDetailView(postTitle: item.attributes.title, postID: item.id, commentCount: item.attributes.commentCount).environmentObject(appsettings)
                                  }
                                  .navigationBarItems(trailing:
                                      Menu {
                                          Section(NSLocalizedString("sorted_by_text", comment: "")){
                                              Button {
                                                  if selectedSortingOption != NSLocalizedString("default_sort", comment: ""){
                                                      discussionData = []
                                                  }
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
                                                  //选择最新帖子的逻辑
                                                  if selectedSortingOption != NSLocalizedString("latest_sort_discussion", comment: ""){
                                                      discussionData = []
                                                  }
                                                  if isHeaderSlideViewEnabled{
                                                      proxy.scrollTo("Top", anchor: .top)
                                                  }else{
                                                      proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                                  }
                                                  selectedSortingOption = NSLocalizedString("latest_sort_discussion", comment: "")
                                              } label: {
                                                  Label(NSLocalizedString("latest_sort_discussion", comment: ""), systemImage: "clock.badge")
                                              }
                                              
                                              Button {
                                                  //选择最新回复的逻辑
                                                  if selectedSortingOption != NSLocalizedString("latest_sort_comment", comment: ""){
                                                      discussionData = []
                                                  }
                                                  if isHeaderSlideViewEnabled{
                                                      proxy.scrollTo("Top", anchor: .top)
                                                  }else{
                                                      proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                                  }
                                                  selectedSortingOption = NSLocalizedString("latest_sort_comment", comment: "")
                                              } label: {
                                                  Label(NSLocalizedString("latest_sort_comment", comment: ""), systemImage: "message.badge")
                                              }
                                              
                                              Button {
                                                  //选择热门帖子的逻辑
                                                  if selectedSortingOption != NSLocalizedString("hot_discussions", comment: ""){
                                                      discussionData = []
                                                  }
                                                  if isHeaderSlideViewEnabled{
                                                      proxy.scrollTo("Top", anchor: .top)
                                                  }else{
                                                      proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                                  }
                                                  selectedSortingOption = NSLocalizedString("hot_discussions", comment: "")
                                              } label: {
                                                  Label(NSLocalizedString("hot_discussions", comment: ""), systemImage: "flame.fill")
                                              }
                                              
                                              Button {
                                                  //选择陈年旧帖的逻辑
                                                  if selectedSortingOption != NSLocalizedString("old_discussions", comment: ""){
                                                      discussionData = []
                                                  }
                                                  if isHeaderSlideViewEnabled{
                                                      proxy.scrollTo("Top", anchor: .top)
                                                  }else{
                                                      proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                                  }
                                                  selectedSortingOption = NSLocalizedString("old_discussions", comment: "")
                                              } label: {
                                                  Label(NSLocalizedString("old_discussions", comment: ""), systemImage: "hourglass.bottomhalf.filled")
                                              }
                                              
                                              Button {
                                                  //选择精华帖子的逻辑
                                                  if selectedSortingOption != NSLocalizedString("frontPage_discussions", comment: ""){
                                                      discussionData = []
                                                  }
                                                  if isHeaderSlideViewEnabled{
                                                      proxy.scrollTo("Top", anchor: .top)
                                                  }else{
                                                      proxy.scrollTo("TopWithoutSlide", anchor: .top)
                                                  }
                                                  selectedSortingOption = NSLocalizedString("frontPage_discussions", comment: "")
                                              } label: {
                                                  Label(NSLocalizedString("frontPage_discussions", comment: ""), systemImage: "house.circle")
                                              }
                                          }
                                      } label: {
                                          Image(systemName: "ellipsis.circle")
                                      }
                                  )
                              }
                              
                              Button {
                                  showingPostingArea.toggle()
                              } label: {
                                  Image(systemName: "plus.bubble.fill")
                                      .font(.title.weight(.semibold))
                                      .padding()
                                      .background(Color(hex: "565dd9").gradient)
                                      .foregroundColor(.white)
                                      .clipShape(Circle())
                                      .shadow(color: shadowColor, radius: 4, x: 0, y: 4)
                              }
                              .padding()
                          }
                      }
                  }
              }
          }
          .persistentSystemOverlays(.hidden)
          .refreshable{
              if !showingPostingArea{
                  await fetchDiscussion()
                  print("fetching when refreshing")
              }
          }
          .onChange(of: appsettings.refreshPostView) { _ in
              currentPage = 1
              Task {
                  await fetchDiscussion()
                  print("fetching when appsettings.refreshPostView changed")
              }
          }
//          .task {
//              await fetchDiscussion()
//              print("fetching in .task")
//          }
          .onAppear {
              Task{
                  await fetchDiscussion()
                  print("fetching when appear")
              }
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
                  print("fetching when selectedSortingOption changed")
              }
          }
          .onSubmit(of: .search) {
              discussionData = []
              discussionIncluded = []
             
              selectedSortingOption = "Search"
              Task{
                  await fetchDiscussion()
                  print("fetching when search submitted")
              }
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
        } else if selectedSortingOption == NSLocalizedString("latest_sort_discussion", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-createdAt")
        }else if selectedSortingOption == NSLocalizedString("latest_sort_comment", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-lastPostedAt")
        }else if selectedSortingOption == "Search"{
            if let encodedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?include=user%2ClastPostedUser%2CmostRelevantPost%2CmostRelevantPost.user%2Ctags%2Ctags.parent%2CclarkwinkelmannWhoReaders.user.groups%2CfirstPost%2Cposts%2Cposts.user&filter%5Bq%5D=\(encodedString)&sort&page%5Bnumber%5D=1")
            }
        }else if selectedSortingOption == NSLocalizedString("hot_discussions", comment: ""){
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-commentCount")
        }else if selectedSortingOption == NSLocalizedString("old_discussions", comment: ""){
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=createdAt")
        }else if selectedSortingOption == NSLocalizedString("frontPage_discussions", comment: ""){
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&frontpage%5D=true&sort=-frontdate")
        }
        
        print("fetching from url: \(String(describing: url))")
        
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
            }

        } catch {
            print("Invalid Discussions Overview And Title Data!", error)
        }
    }
    
    private func fetchDiscussionData(completion: @escaping (Bool) -> Void) {
        var url: URL? = nil // 声明url变量并初始化为nil
        
        if selectedSortingOption == NSLocalizedString("default_sort", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)")
        } else if selectedSortingOption == NSLocalizedString("latest_sort_discussion", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-createdAt")
        }else if selectedSortingOption == NSLocalizedString("latest_sort_comment", comment: "") {
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-lastPostedAt")
        }else if selectedSortingOption == "Search"{
            if let encodedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?include=user%2ClastPostedUser%2CmostRelevantPost%2CmostRelevantPost.user%2Ctags%2Ctags.parent%2CclarkwinkelmannWhoReaders.user.groups%2CfirstPost%2Cposts%2Cposts.user&filter%5Bq%5D=\(encodedString)&sort&page%5Bnumber%5D=1")
            }
        }else if selectedSortingOption == NSLocalizedString("hot_discussions", comment: ""){
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=-commentCount")
        }else if selectedSortingOption == NSLocalizedString("old_discussions", comment: ""){
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&sort=createdAt")
        }else if selectedSortingOption == NSLocalizedString("frontPage_discussions", comment: ""){
            url = URL(string: "\(appsettings.FlarumUrl)/api/discussions?page[number]=\(currentPage)&frontpage%5D=true&sort=-frontdate")
        }
        
        print("fetching from url: \(String(describing: url))")
        
        // 检查url是否为nil
        guard let url = url else {
            print("Invalid URL")
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
            print("Invalid token or not logged in yet!")
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
                } else {
                    print("Decoding to Discussion.self Failed!")
                }
            }
            
            // 请求成功后调用回调
            completion(true)
        }.resume()
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
    
    private func isUserVip(username: String) -> Bool{
        return appsettings.vipUsernames.contains(username)
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
}

//#Preview {
//    PostView()
//}
