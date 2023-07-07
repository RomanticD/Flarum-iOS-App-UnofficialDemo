//
//  newPostView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI
import UIKit

struct newPostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var succeessfullyPosted = false
    @State private var selectedRow: Int? = nil
    @AppStorage("postTitle") var postTitle: String = ""
    @AppStorage("postContent") var postContent: String = ""
    @State private var newPostTitle = ""
    @State private var newPostContent = ""
    @State private var message = "Post"
    @EnvironmentObject var appSettings: AppSettings
    
    
    var body: some View {
        ScrollView{
            VStack {
//                Text("发布新帖")
//                    .font(.title)
//                    .bold()
//                    .padding(.top, 50)
//                
                VStack {
                    HStack {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text("Title")
                            .font(.headline)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    
                    TextField("Enter a title", text: $newPostTitle, axis: .vertical)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
                
                VStack {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text("content")
                            .font(.headline)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    
                    TextField("Enter the content of your discussion", text: $newPostContent, axis: .vertical)
                        .foregroundColor(.gray)
                        .frame(height: 150)
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
                
//                VStack {
//                    HStack {
//                        Image(systemName: "tag")
//                            .font(.system(size: 20))
//                            .foregroundColor(.blue)
//                            .frame(width: 30, height: 30)
//                        
//                        Text("标签")
//                            .font(.headline)
//                            .opacity(0.8)
//                        
//                        Spacer()
//                    }
//                    .padding(.top)
//                    .padding(.leading)
//                    
//
//                    ScrollView {
//                        ForEach(TagManager.shared.tags, id: \.content) { tag in
//                            TagView(tags: [TagViewItem(title: tag.content, isSelected: false)]).padding(.leading)
//                        }
//                    }
//                    Spacer()
//        
//                }

                Button(action: saveNewPost) {
                        Text(message)
                            .bold()
                    }
                .foregroundColor(.white)
                .frame(width: 350, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .opacity(0.8)
//                .disabled(newPostContent.count < 3)

            }
            .onAppear{
                newPostTitle = postTitle
                newPostContent = postContent
            }
//            .background(
//                LinearGradient(gradient: Gradient(colors: [Color(hex: "c2e59c"), Color(hex: "64b3f4")]), startPoint: .leading, endPoint: .trailing))
            .alert(isPresented: $succeessfullyPosted) {
                Alert(title: Text("Post successfully published"),
                      message: nil,
                      dismissButton: .default(Text("OK"), action: {
                        dismiss()
                    }))
            }
        }
    }
    
    func saveNewPost(){
        postTitle = newPostTitle
        postContent = newPostContent
        sendPostRequest()
        
        if newPostTitle.count <= 3 {
            message = "Title too shour！"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = "post"
            }
        }
        
        if newPostTitle.count > 50 {
            message = "Title too long！"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = "post"
            }
        }

    }
    
    private func sendPostRequest() {
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/discussions") else {
            print("invalid Url!")
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "discussions",
                "attributes": [
                    "title": newPostTitle,
                    "content": newPostContent
                ],
                "relationships": [
                    "tags": [
                        "data": [
                            [
                                "type": "tags",
                                "id": "20"
                            ]
                        ]
                    ]
                ]
            ]
        ]

        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize post data to JSON!")
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
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            DispatchQueue.main.async {
                succeessfullyPosted = true
                postTitle = ""
                postContent = ""
                appSettings.refreshPost()
           }
        }.resume()
    }
}

//#Preview {
//    newPostView()
//}
