//
//  newReplyInvitation.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/28.
//

import SwiftUI
import UIKit

struct newReply: View {
    let postID: String
    
    @Environment(\.dismiss) var dismiss
    @State private var succeessfullyReply = false
    @AppStorage("postContent") var replyContent: String = ""
    @State private var newReplyContent = ""
    @EnvironmentObject var appSettings: AppSettings
    @State private var isReplying = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                            .opacity(0.8)
                        
                        Text("Comment")
                            .font(.headline)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    
                    TextField("Say something here...", text: $newReplyContent, axis: .vertical)
                        .foregroundColor(.gray)
                        .frame(height: 100)
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
                
                ZStack {
                    Button(action: {
                        // 调用 saveReply 函数，并在回调闭包中处理请求完成后的操作
                        saveReply { success in
                            if success {
                                // 请求成功，可以执行其他操作
                            } else {
                                // 请求失败，可以执行其他操作或显示错误信息
                            }
                        }
                    }) {
                        HStack {
                            Text(NSLocalizedString("post_button_text", comment: ""))
                                .bold()
                            
                            if isReplying{
                                ProgressView().padding(.leading)
                            }
                        }
                    }
                    .disabled(isReplying)
                    .foregroundColor(.white)
                    .frame(width: 350, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .opacity(0.8)
                    .padding(.bottom)
                }
            }
            .onAppear{
                newReplyContent = replyContent
            }
            .alert(isPresented: $succeessfullyReply) {
                Alert(title: Text("Reply successfully posted"),
                      message: nil,
                      dismissButton: .default(Text("OK"), action: {
                    dismiss()
                }))
            }
        }
    }
    
    // 修改 saveReply 函数，添加一个回调闭包
    func saveReply(completion: @escaping (Bool) -> Void) {
        replyContent = newReplyContent
        
        // 显示进度视图
        isReplying = true
        
        sendPostRequest { success in
            // 隐藏进度视图
            isReplying = false
            
            if success {
                // 请求成功时可以执行其他操作
            } else {
                // 请求失败时可以执行其他操作或显示错误信息
            }
            
            // 调用回调闭包通知调用方请求完成，并传递成功状态
            completion(success)
        }
    }
    
    private func sendPostRequest(completion: @escaping (Bool) -> Void) {
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts") else {
            print("invalid Url!")
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "posts",
                "attributes": [
                    "content": newReplyContent
                ],
                "relationships": [
                    "discussion": [
                        "data": [
                            "type": "discussions",
                            "id": postID
                        ]
                    ]
                ]
            ]
        ]

        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize comment to JSON!")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                        completion(false) // 请求失败时调用回调闭包并传递失败状态
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        print("Invalid response")
                        completion(false) // 请求失败时调用回调闭包并传递失败状态
                        return
                    }
                    
                    DispatchQueue.main.async {
                        succeessfullyReply = true
                        replyContent = ""
                        appSettings.refreshComment()
                        completion(true) // 请求成功时调用回调闭包并传递成功状态
                    }
                }.resume()
    }

}


//#Preview {
//    newReply()
//}
