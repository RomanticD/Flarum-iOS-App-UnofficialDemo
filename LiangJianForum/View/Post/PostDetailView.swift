//
//  PostDetial.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/30.
// MARK: Deprecated - fetch using /api/posts/{id}, which will be slow

import SwiftUI

struct PostDetailView: View {
    let postID: String
    
    @State private var showingPostingArea = false
    @State private var isLiked = false
    @State private var isReplied = false
    @State private var details = [PostDetail]()
    
    var body: some View {
        VStack {
            if details.isEmpty {
                ProgressView()
            } else {
//                HStack {
//                    ForEach(TagManager.shared.tags.prefix(3), id: \.content) { tag in
//                        TagElement(tagInfo: tag)
//                    }
//                }
//                .frame(width: 350, height: 45)
//                .background(Color(hex: "f0f0f5"))
//                .cornerRadius(10)
//                .opacity(0.9)
            }
            
            List(details, id: \.data.id) { detail in
                VStack {
                    HStack {
                        VStack{
                            if let avatarURL = detail.included.first(where: { $0.type == "users"})?.attributes.avatarURL{
                                asyncImage(url: URL(string: avatarURL), frameSize: 60, lineWidth: 1, shadow: 3)
                                    .padding(.top, 10)
                            } else {
                                CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 60, lineWidth: 0.7, shadow: 2)
                                    .opacity(0.3)
                                    .padding(.top, 10)
                            }
                            
                            Spacer()
                        }
                        
                        
                        VStack {
                            HStack {
                                if let displayname = detail.included.first(where: { $0.type == "users" })?.attributes.displayName {
                                    Text(displayname)
                                        .font(.system(size: 12))
                                        .bold()
                                        .foregroundColor(.black)
                                        .padding(.leading, 3)
                                }
                                
                                Text(" \(calculateTimeDifference(from: detail.data.attributes.createdAt))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text(detail.data.attributes.contentHTML.htmlConvertedWithoutUrl)
                                    .padding(.top)
                                    .padding(.leading, 3)
                                    .font(.system(size: 20))
                                Spacer()
                            }
                            
                            if let imageUrls = extractImageURLs(from: detail.data.attributes.contentHTML){
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
//                    LikesAndMentionedButton()
//                        .padding(.bottom, 5)
//                        .padding(.top, 5)
                    
                    Divider()
                }
                .listRowSeparator(.hidden)
            }
            
            Spacer()
        }
        .navigationTitle("帖子回复")
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
        .task {
            await fetchDetails()
        }
    }
    
    private func fetchDetails() async {
        var postReplyID = 1
        var consecutiveNilCount = 0

        while consecutiveNilCount < 5 {
            if let detail = await fetchDetail(postID: "\(postReplyID)") {
                for discussion in detail.included {
                    if discussion.type == "discussions" && discussion.id == "\(postID)" {
                        print("fetch post id: \(postReplyID)")
                        details.append(detail)
                        break
                    }
                }
                postReplyID += 1
                consecutiveNilCount = 0
            } else {
                postReplyID += 1
                consecutiveNilCount += 1
            }
        }
    }
    
    private func fetchDetail(postID: String) async -> PostDetail? {
        guard let url = URL(string: "https://hk.maxmc.cc/api/posts/\(postID)") else {
            print("Invalid URL")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(PostDetail.self, from: data) {
                return decodedResponse
            }
        } catch {
            print("Invalid Post Detail Data!", error)
        }
        
        return nil
    }
}

//#Preview {
//    PostDetailView(postID: "3")
//}

