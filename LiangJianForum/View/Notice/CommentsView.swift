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
    @Binding var avatarUrl: String
    @Binding var searchTerm: String
    @EnvironmentObject var appsettings: AppSettings
    @State private var currentPageOffset = 0
    @State private var isLoading = false
    @State private var hasNextPage = false
    @State private var hasPrevPage = false
        
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
        if hasNextPage || hasPrevPage {
            HStack{
                Button(action: {
                    if currentPageOffset >= 20 {
                        currentPageOffset -= 20
                    }
                    isLoading = true
                    Task {
//                        await fetchUserPostsInfo()
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
//                        await fetchUserPostsInfo()
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
//                        await fetchUserPostsInfo()
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
        
        
        ScrollViewReader { proxy in
            if userCommentData.isEmpty{
                Text("Not supported")
                    .foregroundStyle(.secondary)
                ProgressView()
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
                                                if  avatarUrl != ""{
                                                    asyncImage(url: URL(string: avatarUrl), frameSize: 50, lineWidth: 1, shadow: 3)
                                                        .padding(.top, 10)
                                                } else {
                                                    CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                                                        .opacity(0.3)
                                                        .padding(.top, 10)
                                                }
                                                
                                                if let displayname = self.displayname{
                                                    Text(displayname)
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
                                                
                                                Spacer()
                                            }
                                            .task{
                                                CommentCount = await fetchCommentCount(DiscussionId)
                                            }
                                            
                                            HStack {
                                                Text(LocalizedStringKey(contentHtml.htmlConvertedWithoutUrl))
                                                    .tracking(0.5)
                                                    .lineSpacing(7)
                                                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                                    .padding(.top)
                                                    .padding(.leading, 3)
                                                    .font(.system(size: 15))
                                                
                                                Spacer()
                                            }
                                            
                                            if let imageUrls = extractImageURLs(from: contentHtml){
                                                ForEach(imageUrls, id: \.self) { url in
                                                    AsyncImage(url: URL(string: url)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 270)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 3)
                                                            .overlay(Rectangle()
                                                                .stroke(.white, lineWidth: 1)
                                                                .cornerRadius(10))
                                                            .padding(.bottom)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .onTapGesture {
                                                        if let imgurl = URL(string: url) {
                                                            UIApplication.shared.open(imgurl)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .navigationDestination(for: Datum8.self){item in
                                            fastPostDetailView(postTitle: DiscussionTitle, postID: DiscussionId, commentCount: CommentCount).environmentObject(appsettings)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .id("AllUserComments")
                }
                .onChange(of: currentPageOffset){ _ in
                    withAnimation {
                        proxy.scrollTo("AllUserComments", anchor: .top)
                    }
                }
                .searchable(text: $searchTerm, prompt: "Search")
            }
        }
        .navigationTitle("TA的最新动态")
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
    
    private func fetchUserPostsInfo() async {

        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(appsettings.username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
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

                if decodedResponse.links.prev != nil && currentPageOffset != 0{
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
}

//#Preview {
//    CommentsView()
//}
