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
    
    var body: some View {
        NavigationStack {
            if tags.isEmpty{
                HStack {
                    Text("Loading...").foregroundStyle(.secondary)
                    ProgressView()
                }
            }else{
                List {
                    ForEach(tags, id: \.id) { tag in
                        NavigationLink(value: tag){
                            TagElement(tag: tag, fontSize: 20)
                        }
                    }
                }
                .navigationDestination(for: Datum6.self){data in
                    TagDetail(selectedTag: data)
                }
                .navigationTitle("All Tags")
            }
        }
        .task {
            await fetchTagsData()
        }
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
