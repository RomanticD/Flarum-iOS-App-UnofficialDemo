//
//  FavoriteButton.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/5.
//

import SwiftUI

enum FollowButtonMode {
    case follow
    case unfollow
}

struct FavoriteButton: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appSettings: AppSettings
    let isSubscription : Bool
    let discussionId : String
    @State private var subscription : Bool
    @State private var isUserSubscribed: Bool
    @State private var showAlert = false
    @State private var message = ""
    
    init(isSubscription: Bool, discussionId: String) {
        self.discussionId = discussionId
        self.isSubscription = isSubscription
        _subscription = State(initialValue: isSubscription)
        _isUserSubscribed = State(initialValue: isSubscription)
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                if isUserSubscribed{
                    subscription = false
                    message = NSLocalizedString("unfollow_success_message", comment: "")
                    
                    sendFollowRequest(completion: { success in
                        showAlert = true
                        isUserSubscribed = false
                        print("successfuly unfollow the post, ID: \(discussionId)")
                    }, mode: .unfollow)
                }else{
                    subscription = true
                    message = NSLocalizedString("follow_success_message", comment: "")
                    
                    sendFollowRequest(completion: { success in
                        showAlert = true
                        isUserSubscribed = true
                        print("successfuly follow the post, ID: \(discussionId)")
                    }, mode: .follow)
                }
            }) {
                Image(systemName: subscription ? "star.fill" : "star")
                    .font(.system(size: 15))
                    .foregroundColor(subscription ? .yellow : Color(UIColor.quaternaryLabel))
            }
            .buttonStyle(.plain)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(message),
                  message: nil,
                  dismissButton: .default(Text("OK"), action: {
                    dismiss()
                }))
        }
    }
    
    private func sendFollowRequest(completion: @escaping (Bool) -> Void, mode : FollowButtonMode) {
        var follow = false
        switch mode {
        case .follow:
            follow = true
        case .unfollow:
            follow = false
        }
        
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/discussions/\(self.discussionId)") else {
            print("invalid Url!")
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "discussions",
                "attributes": [
                    "subscription": follow == true ? "follow" : nil
                ],
                "id": self.discussionId
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
