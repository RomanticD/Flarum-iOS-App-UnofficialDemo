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
    @State private var tags = [Datum6]()
    @State private var selectedButtonIds: [String] = []
    
    
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
                            .frame(width: 30, height: 30)
                        
                        Text("Select Tags")
                            .font(.headline)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    

                    ScrollView {
                        ForEach(tags, id: \.id) { tag in
                            HStack {
                                TagButton(id: tag.id, tagColor: tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)), title: tag.attributes.name, selectedButtonIds: $selectedButtonIds).padding(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                    Spacer()
        
                }

                Button(action: saveNewPost) {
                        Text(message)
                            .bold()
                    }
                .foregroundColor(.white)
                .frame(width: 350, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .opacity(0.8)
                .padding(.top)

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
    
    func saveNewPost(){
        postTitle = newPostTitle
        postContent = newPostContent
        sendPostRequest()
        
        if newPostTitle.count <= 3 {
            message = "Title too short！"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = "post"
            }
        }
        
        if newPostContent.count <= 3 {
            message = "Content too short！"
            
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
}

//#Preview {
//    newPostView()
//}
