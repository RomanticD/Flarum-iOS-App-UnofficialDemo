//
//  ChangeProfileDetail.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/5.
//

import SwiftUI
import UIKit

struct ChangeProfileDetail: View {
    @Environment(\.dismiss) var dismiss
    @State private var succeessfullyChanged = false
    @AppStorage("postTitle") var displayName: String = ""
    @State private var newDisplayName = ""
    @State private var message = "保存"
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
                        Image(systemName: "display")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text("显示昵称")
                            .font(.headline)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    
                    TextField("输入昵称", text: $newDisplayName, axis: .vertical)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .padding(.bottom)
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

            }
            .onAppear{
                newDisplayName = displayName
            }
//            .background(
//                LinearGradient(gradient: Gradient(colors: [Color(hex: "c2e59c"), Color(hex: "64b3f4")]), startPoint: .leading, endPoint: .trailing))
            .alert(isPresented: $succeessfullyChanged) {
                Alert(title: Text("保存成功"),
                      message: nil,
                      dismissButton: .default(Text("确定"), action: {
                        dismiss()
                    }))
            }
        }
    }
    
    func saveNewPost(){
        displayName = newDisplayName
        sendPostRequest()
        
        if newDisplayName.count <= 2 {
            message = "昵称过短请重试！"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = "保存"
            }
        }
        
        if newDisplayName.count > 20 {
            message = "昵称过长请重试！"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                message = "保存"
            }
        }

    }
    
    private func sendPostRequest() {
        print("current userId when changing profile: \(appSettings.userId)")
        
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else {
            print("invalid Url!")
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "users",
                "attributes": [
                    "nickname": "\(displayName)"
                ],
                "id": "\(appSettings.userId)"
            ]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize post data(change profile) to JSON!")
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
                succeessfullyChanged = true
                displayName = ""
                appSettings.refreshProfile()
           }
        }.resume()
    }
}
