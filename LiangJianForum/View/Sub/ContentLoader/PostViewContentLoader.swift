//
//  PostViewContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/6.
//

import SwiftUI

struct PostViewContentLoader: View {
    @Environment(\.colorScheme) var colorScheme
    var selectedSortingOption : String
    @State private var isHeaderSlideViewEnabled = true
    
    var shadowColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    PaginationView(hasPrevPage: true,
                                   hasNextPage: true,
                                   currentPage: .constant(1),
                                   isLoading: .constant(true),
                                   fetchDiscussion: nil,
                                   fetchUserInfo: nil,
                                   mode: .page
                    )
                    
                    List {
                        // MARK: - if Flarum has HeaderSlide Plugin installed with api endpoint \(appsettings.FlarumUrl)/api/header-slideshow/list
                        if selectedSortingOption != "Search"{
                            if isHeaderSlideViewEnabled{
                                Section{
                                    ShimmerEffectBox()
                                        .frame(height: 100)
                                }
                                .id("Top")
                                .listRowInsets(EdgeInsets())
                            }

                        }
                                                              
                        Section{
                            ForEach(0..<6) { item in
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
                    .searchable(text: .constant(""), prompt: "Search")
                    .navigationTitle(selectedSortingOption)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing:
                        Menu {
                            Section(NSLocalizedString("sorted_by_text", comment: "")){
                                Button {
                                } label: {
                                    Label(NSLocalizedString("default_sort", comment: ""), systemImage: "seal")
                                }.disabled(true)
                            
                                Button {
                                } label: {
                                    Label(NSLocalizedString("latest_sort_discussion", comment: ""), systemImage: "timer")
                                }.disabled(true)
                                
                                Button {
                                } label: {
                                    Label(NSLocalizedString("latest_sort_comment", comment: ""), systemImage: "message.badge")
                                }.disabled(true)
                                
                                Button {
                                } label: {
                                    Label(NSLocalizedString("hot_discussions", comment: ""), systemImage: "flame.fill")
                                }.disabled(true)
                                
                                Button {
                                } label: {
                                    Label(NSLocalizedString("old_discussions", comment: ""), systemImage: "hourglass.bottomhalf.filled")
                                }.disabled(true)
                                
                                Button {
                                } label: {
                                    Label(NSLocalizedString("frontPage_discussions", comment: ""), systemImage: "house.circle")
                                }.disabled(true)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    )
                }
                
                Button {
                } label: {
                    Image(systemName: "plus.bubble.fill")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color(hex: "565dd9").gradient)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(color: shadowColor, radius: 4, x: 0, y: 4)
                }
                .padding()
            }
        }
    }
}

//#Preview {
//    PostViewContentLoader()
//}
