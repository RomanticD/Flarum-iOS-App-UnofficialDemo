//
//  PostViewContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/6.
//

import SwiftUI

struct PostViewContentLoader: View {
    @EnvironmentObject var appsettings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedSortingOption : String
    @Binding var discussionData : [Datum]
    @State private var isHeaderSlideViewEnabled = true
    @Binding var isCheckInSucceeded : Bool
    var shadowColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    PaginationView(hasPrevPage: false,
                                   hasNextPage: false,
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
                            if discussionData.isEmpty && selectedSortingOption == NSLocalizedString("subsription_sort", comment: "") {
                                HStack {
                                    Spacer()
                                    
                                    Text("暂无收藏")
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                }
                            }
                            
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
                                            
                                            FavoriteButton(isSubscription: false, discussionId: "0")
                                            
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
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Menu {
                                Section(NSLocalizedString("tabbar_operations", comment: "")){
                                    Button {
                                        if selectedSortingOption != NSLocalizedString("subsription_sort", comment: ""){
                                            discussionData = []
                                        }
                                        //选择收藏帖子的逻辑
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("subsription_sort", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("subsription_sort", comment: ""), systemImage: "star.fill")
                                            .foregroundStyle(Color.yellow)
                                    }
                                }
                                
                                Section(NSLocalizedString("sorted_by_text", comment: "")){
                                    Button {
                                        if selectedSortingOption != NSLocalizedString("default_sort", comment: ""){
                                            discussionData = []
                                        }
                                        //选择默认的逻辑
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("default_sort", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("default_sort", comment: ""), systemImage: "seal")
                                    }
                                
                                    Button {
                                        //选择最新帖子的逻辑
                                        if selectedSortingOption != NSLocalizedString("latest_sort_discussion", comment: ""){
                                            discussionData = []
                                        }
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("latest_sort_discussion", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("latest_sort_discussion", comment: ""), systemImage: "bubble.middle.bottom")
                                    }
                                    
                                    Button {
                                        //选择最新回复的逻辑
                                        if selectedSortingOption != NSLocalizedString("latest_sort_comment", comment: ""){
                                            discussionData = []
                                        }
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("latest_sort_comment", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("latest_sort_comment", comment: ""), systemImage: "clock.badge")
                                    }
                                    
                                    Button {
                                        //选择热门帖子的逻辑
                                        if selectedSortingOption != NSLocalizedString("hot_discussions", comment: ""){
                                            discussionData = []
                                        }
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("hot_discussions", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("hot_discussions", comment: ""), systemImage: "flame.fill")
                                    }
                                    
                                    Button {
                                        //选择陈年旧帖的逻辑
                                        if selectedSortingOption != NSLocalizedString("old_discussions", comment: ""){
                                            discussionData = []
                                        }
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("old_discussions", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("old_discussions", comment: ""), systemImage: "hourglass.bottomhalf.filled")
                                    }
                                    
                                    Button {
                                        //选择精华帖子的逻辑
                                        if selectedSortingOption != NSLocalizedString("frontPage_discussions", comment: ""){
                                            discussionData = []
                                        }
//                                        if isHeaderSlideViewEnabled{
//                                            proxy.scrollTo("Top", anchor: .top)
//                                        }else{
//                                            proxy.scrollTo("TopWithoutSlide", anchor: .top)
//                                        }
                                        selectedSortingOption = NSLocalizedString("frontPage_discussions", comment: "")
                                    } label: {
                                        Label(NSLocalizedString("frontPage_discussions", comment: ""), systemImage: "house.circle")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Menu {
                                Section(NSLocalizedString("tabbar_operations", comment: "")){
                                    CheckinButton(isCheckInSucceeded: $isCheckInSucceeded)
                                }
                            } label: {
                                Image(systemName: "list.bullet")
                            }
                        }
                    }
                }
                
                Button {
                } label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color("FlarumTheme").gradient)
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
