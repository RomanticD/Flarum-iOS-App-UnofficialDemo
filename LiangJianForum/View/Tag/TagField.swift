//
//  TagField.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/26.
//
import SwiftUI

struct TagField: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var tags = [Datum6]()
    @State private var searchTerm = ""
    
    var filteredTags : [Datum6] {
        var filteredItems: [Datum6] = []
        
        guard !searchTerm.isEmpty else { return getParentTagsFromFetching(from: tags) }
        
        for item in getParentTagsFromFetching(from: tags) {
            if item.attributes.name.localizedCaseInsensitiveContains(searchTerm){
                filteredItems.append(item)
            }
        }
        return filteredItems
    }
    
    var body: some View {
        NavigationStack {
            if tags.isEmpty{
                TagFieldContentLoader()
            }else{
                List {
                    ForEach(filteredTags, id: \.id) { tag in
                        if getChildTags(parentTag: tag, dataFetched: tags).isEmpty{
                            NavigationLink(value: tag){
                                HStack {
                                    TagElement(tag: tag, fontSize: 20)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Spacer()
                                }
                            }
                        }else{
                            NavigationLink(value: getChildTags(parentTag: tag, dataFetched: tags)){
                                HStack {
                                    TagElement(tag: tag, fontSize: 20)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .searchable(text: $searchTerm, prompt: "Search")
                .navigationTitle("All Tags")
                .navigationDestination(for: Datum6.self){tag in
                    TagDetail(selectedTag: tag)
                }
                .navigationDestination(for: [Datum6].self){tagsArray in
                    List{
                        ForEach(tagsArray, id: \.id){tag in
                            NavigationLink(value: tag){
                                HStack {
                                    TagElement(tag: tag, fontSize: 20)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Datum6.self){tag in
                        TagDetail(selectedTag: tag)
                    }
                }
            }
        }
        .onAppear{
            fetchTags{success in
                if success{
                    print("successfully decode tags data in TagField!")
                }
            }
        }
    }
    
    private func fetchTags(completion: @escaping (Bool) -> Void) {
        // clearData()
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/tags") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        // 创建URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 使用GET方法
        
        // 设置请求头
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appSettings.token != "" {
            request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Invalid token or not logged in yet!")
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
            
            // 在请求成功时处理数据
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(TagsData.self, from: data) {
                    print("Successfully decoding use TagsData.self")
                    self.tags = decodedResponse.data
                } else {
                    print("Decoding to TagsData Failed!")
                }
            }
            
            // 请求成功后调用回调
            completion(true)
        }.resume()
    }
}
