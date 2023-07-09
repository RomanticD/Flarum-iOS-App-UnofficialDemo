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
    @State private var selection : String = "🍿Comment"
    let filterOptions: [String] = ["🍿Comment", "🍺Likes", "⛳️Follow"]
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
            if userCommentData.isEmpty || userCommentData.isEmpty{
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
            }else{
                Picker(
                        selection : $selection,
                        label: Text("Picker"),
                        content:{
                            ForEach(filterOptions.indices){index in
                                Text(filterOptions[index]).tag(filterOptions[index])
                            }
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 1), value: selection)

                if selection == "🍿Comment"{
                    if hasPrevPage || hasNextPage {
                        HStack{
                            Button(action: {
                                if currentPageOffset >= 20 {
                                    currentPageOffset -= 20
                                }
                                isLoading = true
                                Task {
                                    await fetchUserPosts()
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
                                    await fetchUserPosts()
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
                                    await fetchUserPosts()
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
                        }
                        .padding(.top, 5)
                    }
                    
                    List{
                        ForEach(filteredCommentData, id: \.id)  {item in
                            let DiscussionId = item.relationships.discussion.data.id
                            let DiscussionTitle = findDiscussionTitle(id: item.relationships.discussion.data.id)
                            var CommentCount = 0
                            let sectionTitle = "🍾 In \"" + DiscussionTitle + "\""
                            
                            if item.attributes.contentType == "comment"{
                                Section(sectionTitle){
                                    if let contentHtml = item.attributes.contentHTML{
                                        NavigationLink(value: item){
                                            VStack{
                                                HStack{
                                                    if  avatarUrl != ""{
                                                        asyncImage(url: URL(string: avatarUrl), frameSize: 60, lineWidth: 1, shadow: 3)
                                                                .padding(.top, 10)
                                                    } else {
                                                        CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 60, lineWidth: 0.7, shadow: 2)
                                                                .opacity(0.3)
                                                                .padding(.top, 10)
                                                    }

                                                    Text(appsettings.username)
                                                            .font(.system(size: 12))
                                                            .bold()
                                                            .padding(.leading, 3)
                                                            .foregroundColor(colorScheme == .dark ? .white : .black)

                                                    Text(calculateTimeDifference(from: item.attributes.createdAt))
                                                            .font(.system(size: 8))
                                                            .foregroundColor(.gray)

                                                    Spacer()
                                                }
                                                .padding(.bottom)
                                                .task{
                                                    CommentCount = await fetchCommentCount(DiscussionId)
                                                }

                                                Text(contentHtml.htmlConvertedWithoutUrl)
                                                    .padding(.bottom)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                            }
                                            .navigationDestination(for: Datum8.self){item in
                                                fastPostDetailView(postTitle: DiscussionTitle, postID: DiscussionId, commentCount: CommentCount).environmentObject(appsettings)
                                            }
                                        }
                                    }
                                }
                            }
                        }

    //                Section("🧐 All \(appsettings.username)'s comment"){
    //                    ForEach(userCommentData, id: \.id) { item in
    //                        Text(findDiscussionTitle(id: item.relationships.discussion.data.id))
    //                                .padding(.bottom)
    //                                .bold()
    //
    //                        if let contentHtml = item.attributes.contentHTML{
    //                            Text(contentHtml.htmlConvertedWithoutUrl)
    //                        }
    //                    }
    //
    ////                    ForEach(notificationData, id: \.id) { item in
    ////                        if let contentType = item.attributes?.contentType{
    ////                            Text(contentType)
    ////                        }
    ////                    }
    //                }
                    }
                    .searchable(text: $searchTerm, prompt: "Search")
                    .navigationTitle("Notification Center")
                }else if selection == "🍺Likes"{
                    List{
                        Section("🤩Likes"){
                            Text("Developing...")
                        }
                    }.navigationTitle("Notification Center")
                }else if selection == "⛳️Follow"{
                    List{
                        Section("🥳Follow"){
                            Text("Developing...")
                        }
                    }.navigationTitle("Notification Center")
                }else{
                    ProgressView()
                }
            }
        }
        .task {
            await fetchUserProfile()
            await fetchUserPosts()
        }
        
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

//    private func fetchNotifications() async {
//
//        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/notifications") else{
//            print("Invalid Notification URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.setValue("Token \(appsettings.token)", forHTTPHeaderField: "Authorization")
//
//        do{
//            let (data, _) = try await URLSession.shared.data(for: request)
//
//            if let decodedResponse = try? JSONDecoder().decode(NotificationData.self, from: data){
//                self.notificationData = decodedResponse.data
//
//                if let included = decodedResponse.included{
//                    self.notificationIncluded = included
//                }
//
//                if decodedResponse.links.next != nil{
//                    self.hasNextPage = true
//                }
//
//                if decodedResponse.links.prev != nil && currentPage != 1{
//                    self.hasPrevPage = true
//                }else{
//                    self.hasPrevPage = false
//                }
//
//                print("successfully decode notification data")
//                print("current page: \(currentPage)")
//                print("has next page: \(hasNextPage)")
//                print("has prev page: \(hasPrevPage)")
//            }
//
//        } catch {
//            print("Invalid Notification Data!", error)
//        }
//    }

    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/users/\(appsettings.userId)") else{
            print("Invalid URL")
            return
        }
        print("Fetching User Info : id \(appsettings.userId) at: \(url)")

        do{
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                appsettings.username = decodedResponse.data.attributes.username

                if let avatarUrl = decodedResponse.data.attributes.avatarURL{
                    self.avatarUrl = avatarUrl
                }
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }

    private func fetchUserPosts() async {

        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(appsettings.username)&page%5Boffset%5D=\(currentPageOffset)") else{
            print("Invalid URL")
            return
        }

        do{
           print("fetching from \(url)")
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                print("successfully decode user's comment data")
                print("current page: \(currentPageOffset)")
                print("has next page: \(hasNextPage)")
                print("has prev page: \(hasPrevPage)")
            }

        } catch {
            print("Invalid user's comment Data!" ,error)
        }
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
            print("Invalid Discussions And Title Data in notification tab!" ,error)
        }
        
        return 0
    }
}


//#Preview {
//    NoticeView()
//}

