//
//  LikesAndMentionedButton.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/27.
//

import SwiftUI

struct LikesAndMentionedButton: View {
    @EnvironmentObject var appSettings: AppSettings
    
    let postId: String
    let likesCount: Int?
    let mentionedByCount: Int?
    var isUserLiked: Bool
    @State private var isMentioned: Bool
    @State private var isLiked: Bool
    @State private var isCurrentUserLiked: Bool
    @State private var likesTapCount = 0
    @State private var likesTapCount_liked = 0
    @State private var likesNum : Int
    
    init(postId: String, likesCount: Int?, mentionedByCount: Int?, isUserLiked: Bool) {
        self.postId = postId
        self.likesCount = likesCount ?? 0
        self.mentionedByCount = mentionedByCount ?? 0
        self.isUserLiked = isUserLiked
        _isMentioned = State(initialValue: mentionedByCount != nil && mentionedByCount! > 0)
        _likesNum = State (initialValue: likesCount ?? 0)
        _isLiked = State(initialValue: isUserLiked)
        _isCurrentUserLiked = State(initialValue:  isUserLiked)
    }
    
    var body: some View {
        HStack{
            Spacer()

            //点赞
            HStack(spacing: 0){
                Button(action: {
                    //如果该评论点赞中没有当前用户
                    if !isCurrentUserLiked{
                        likesTapCount  += 1
                        isLiked.toggle()
                        
                        if likesTapCount % 2 == 1 {
                            sendLikesRequest(completion: { success in
                                if success{
                                    likesNum += 1
                                } else{
                                    
                                }
                            }, status: .like)
                        } else {
                            sendLikesRequest(completion: { success in
                                if success && likesNum > 0{
                                    likesNum -= 1
                                } else{
                                    
                                }
                            }, status: .unLike)
                        }
                    }else{
                        //如果用户已经点赞过该条评论
                        likesTapCount_liked += 1
                        isLiked.toggle()
                        
                        if likesTapCount_liked % 2 == 1 {
                            sendLikesRequest(completion: { success in
                                if success && likesNum > 0{
                                    likesNum -= 1
                                } else{
                                    
                                }
                            }, status: .unLike)
                        } else {
                            sendLikesRequest(completion: { success in
                                if success{
                                    likesNum += 1
                                } else{
                                    
                                }
                            }, status: .like)
                        }
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 15))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 2)
                
                if likesNum != 0 {
                    Text("\(likesNum)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            //回复
            HStack(spacing: 0) {
                Button(action: {
                    
                }) {
                    Image(systemName: isMentioned ? "arrowshape.turn.up.left.fill" : "arrowshape.turn.up.left")
                        .font(.system(size: 15))
                        .foregroundColor(.mint)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 2)
                
                if let mentionedBy = mentionedByCount, mentionedBy > 0 {
                    Text("\(mentionedBy)")
                        .font(.system(size: 12))
                        .foregroundColor(.mint)
                }
            }
        }
    }
    
    private func sendLikesRequest(completion: @escaping (Bool) -> Void, status: likeOrUnlike) {
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts/\(postId)") else {
            print("invalid Url!")
            completion(false)
            return
        }
       
        var isLikedValue = false
       switch status {
       case .like:
           isLikedValue = true
       case .unLike:
           isLikedValue = false
       }
       
       let parameters: [String: Any] = [
           "data": [
               "type": "posts",
               "attributes": [
                   "isLiked": isLikedValue
               ],
               "id": postId
           ]
       ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize post data to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appSettings.token != ""{
            request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
        }else{
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
            
            completion(true)
        }.resume()
    }
}

enum likeOrUnlike{
    case like
    case unLike
}
