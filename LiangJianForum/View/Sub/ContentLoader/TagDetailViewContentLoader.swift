//
//  TagDetailViewContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/6.
//

import SwiftUI

struct TagDetailViewContentLoader: View {
    let selectedTag : Datum6
    
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSortingOption = NSLocalizedString("latest_sort_comment", comment: "")
    @State private var isHeaderSlideViewEnabled = true
    
    var shadowColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
       
        ZStack(alignment: .bottomTrailing) {
            VStack {
                List {
                    Section{
                        ForEach(0..<8) { item in
                            HStack {
                                VStack {
                                    NavigationLink(value: item){
                                        //MARK: 头像及标题
                                        HStack{
                                            ShimmerEffectBox()
                                                .frame(width: 40, height: 40)
                                                .cornerRadius(20)
                                            
                                            VStack {
                                                HStack {
                                                    ShimmerEffectBox()
                                                        .frame(height: 20)
                                                    
                                                    Spacer()
                                                }


                                            }
                                            Spacer()
                                        }
                                    }
                                    
                                    //MARK: 最后更新时间 评论数 阅读数量 收藏
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(Color(uiColor: UIColor.systemGray5))
                                            .font(.system(size: 10))
                                        
                                        ShimmerEffectBox()
                                            .frame(width: 30, height: 10)
                                            .padding(.leading, 2)
                                        
                                        Image(systemName: "bubble.middle.bottom.fill")
                                            .foregroundColor(Color(uiColor: UIColor.systemGray5))
                                            .padding(.leading)
                                            .font(.system(size: 10))
                                        
                                        ShimmerEffectBox()
                                            .frame(width: 30, height: 10)
                                            .padding(.leading, 2)
                                        
                                        FavoriteButton()
                                        
                                    }
                                    .padding(.top, 15)
                                    .padding(.bottom, 5)

                                    Divider()
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .id("TopWithoutSlide")
                }
                .textSelection(.enabled)
//                    .searchable(text: .constant(""), prompt: "Search")
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationTitle(self.selectedTag.attributes.name)
                .toolbarBackground(selectedTag.attributes.color.isEmpty ? Color.gray.opacity(0.8) : Color(hex: removeFirstCharacter(from: selectedTag.attributes.color)).opacity(0.8), for: .automatic)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Menu {
                        Section(NSLocalizedString("tabbar_operations", comment: "")){
                            Button {
                            } label: {
                                Label(NSLocalizedString("start_new_discussion_message", comment: ""), systemImage: "plus.bubble.fill")
                            }.disabled(true)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                )
            }
        }
    }
}
