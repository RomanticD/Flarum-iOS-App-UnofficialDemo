//
//  NoticeView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/1.
//

import SwiftUI

struct NoticeView: View {
    @State private var currentPage = 1
    @EnvironmentObject var appsettings: AppSettings
    @State private var hasNextPage = false
    @State private var hasPrevPage = false
    @State private var notificationData = [Datum7]()
    @State private var notificationIncluded = [Included7]()
    
    var body: some View {
        NavigationStack{
            List{
                Section("🧐Message"){
                    Text("Developing...")
                    
                    ForEach(notificationData, id: \.id) { item in
                        if let contentType = item.attributes?.contentType{
                            Text(contentType)
                        }
                    }
                }
                Section("🤩Favorite"){
                    Text("Developing...")
                }
                Section("🥳Follow"){
                    Text("Developing...")
                }
            }
            .navigationTitle("Notification Center")
        }
        .task {
            await fetchNotifications()
        }
        
    }
    
    private func fetchNotifications() async {
        
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/notifications") else{
            print("Invalid Notification URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Token \(appsettings.token)", forHTTPHeaderField: "Authorization")
        
        do{
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let decodedResponse = try? JSONDecoder().decode(NotificationData.self, from: data){
                self.notificationData = decodedResponse.data
                
                if let included = decodedResponse.included{
                    self.notificationIncluded = included
                }

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }
                
                if decodedResponse.links.prev != nil && currentPage != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }
                
                print("successfully decode notification data")
                print("current page: \(currentPage)")
                print("has next page: \(hasNextPage)")
                print("has prev page: \(hasPrevPage)")
            }
            
        } catch {
            print("Invalid Notification Data!", error)
        }
    }
}



#Preview {
    NoticeView()
}

