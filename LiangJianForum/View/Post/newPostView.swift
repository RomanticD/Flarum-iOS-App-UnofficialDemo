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
    @State private var message = NSLocalizedString("post_button_text", comment: "")
    @EnvironmentObject var appSettings: AppSettings
    @State private var tags = [Datum6]()
    @State private var selectedButtonIds: [String] = []
    @State private var isPosting = false
    
    
    var body: some View {
        ScrollView{
            VStack {
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
                        
                        Text("Content")
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
                
                VStack {
                    HStack {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        
                        Text("Select Tags")
                            .font(.headline)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    

                    ForEach(tags, id: \.id) { tag in
                        HStack {
                            TagButton(id: tag.id, tagColor: tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)), title: tag.attributes.name, selectedButtonIds: $selectedButtonIds).padding(.leading)

                            Spacer()
                        }
                    }
                    
                    Spacer()
                }

                Button(action: saveNewPost) {
                     HStack{
                        Text(message)
                            .bold()
                         
                         if isPosting{
                             ProgressView()
                                 .padding(.leading)
                         }
                    }
                }
                .foregroundColor(.white)
                .frame(width: 350, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .opacity(0.8)
                .padding(.top)
                .disabled(isPosting)

            }
            .onAppear{
                newPostTitle = postTitle
                newPostContent = postContent
            }
            .alert(isPresented: $succeessfullyPosted) {
                Alert(title: Text("Post successfully published"),
                      message: nil,
                      dismissButton: .default(Text("OK"), action: {
                        dismiss()
                    }))
            }
        }
        .task {
            await fetchTagsData()
        }
    }
    
    private func clearData(){
        newPostTitle = ""
        postTitle = ""
        newPostContent = ""
        postContent = ""
    }
    
    func saveNewPost() {
        // 在按钮点击后设置isPosting为true，禁用按钮
        isPosting = true
        
        postTitle = newPostTitle
        postContent = newPostContent

        if newPostTitle.count <= 3 {
            isPosting = false // 恢复按钮可用性
            message = NSLocalizedString("title_too_short_message", comment: "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = NSLocalizedString("post_button_text", comment: "")
            }
            return
        }

        if newPostContent.count <= 3 {
            isPosting = false // 恢复按钮可用性
            message = NSLocalizedString("content_too_short_message", comment: "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = NSLocalizedString("post_button_text", comment: "")
            }
            return
        }

        if newPostTitle.count > 50 {
            isPosting = false // 恢复按钮可用性
            message = NSLocalizedString("title_too_long_message", comment: "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = NSLocalizedString("post_button_text", comment: "")
            }
            
            return
        }

        sendPostRequest { success in
            if success {
                // 发送成功的处理逻辑
                succeessfullyPosted = true
                isPosting = false // 恢复按钮可用性
                clearData()
            } else {
                // 发送失败的处理逻辑
                showMessageAndEnableButton(message: NSLocalizedString("post_tags_exceed_limit", comment: ""))
            }
            
            // 无论成功或失败，都在回调中恢复按钮可用性
            isPosting = false
        }
    }
    
    private func sendPostRequest(completion: @escaping (Bool) -> Void) {
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/discussions") else {
            print("invalid Url!")
            completion(false)
            return
        }
        
        var selectedTags: [[String: Any]] = []
        
        for tagId in selectedButtonIds {
            selectedTags.append(["type": "tags", "id": tagId])
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
                        "data": selectedTags
                    ]
                ]
            ]
        ]

        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize post data to JSON!")
            completion(false)
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
    
    private func fetchTagsData() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/tags") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(TagsData.self, from: data) {
                self.tags = decodedResponse.data
            }
        } catch {
            print("Invalid Tags Data!", error)
        }
    }
    
    private func showMessageAndEnableButton(message: String) {
        isPosting = false // 恢复按钮可用性
        self.message = message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.message = NSLocalizedString("post_button_text", comment: "")
        }
    }
}

//#Preview {
//    newPostView()
//}
