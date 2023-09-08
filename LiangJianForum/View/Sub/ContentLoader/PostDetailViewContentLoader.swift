//
//  PostDetailViewContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/6.
//

import SwiftUI

struct PostDetailViewContentLoader: View {
    let postTitle: String
    let postID: String
    let commentCount: Int
    
    @Environment(\.colorScheme) var colorScheme
    
    var shadowColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
        VStack {
                HStack {
                    Spacer()
                    HStack {
                        ShimmerEffectBox()
                            .frame(width: 15, height: 15)
                        
                        ShimmerEffectBox()
                            .frame(width: 60, height: 15)
                            .padding(.leading, 5)
                    }
                    Spacer()
                }
                                
                ZStack(alignment: .bottomTrailing) {
                    List{
                        Section("帖子回复"){
                            // MARK: - Post list
                            ForEach(0..<commentCount) { item in
                                VStack {
                                    HStack {
                                        VStack {
                                            NavigationLink(value: item){
                                                HStack {
                                                    ShimmerEffectBox()
                                                        .frame(width: 50, height: 50)
                                                        .cornerRadius(25)
                                                        .padding(.top, 10)
                                                        .padding(.leading, 6)
                                                    
                                                    ShimmerEffectBox()
                                                        .padding(.leading, 3)
                                                        .frame(height: 12)
                                                    
                                                    Spacer()
                                                }
                                            }
                                            
                                            ShimmerEffectBox()
                                                .frame(height: 75)
                                                .cornerRadius(5)
                                                .padding(.top)
                                                .padding(.leading, 6)
                                        }
                                    }
                                    
                                    LikesAndMentionedButton(postId: "0",
                                                            likesCount: 0,
                                                            mentionedByCount: 0,
                                                            isUserLiked : false
                                    )
                                        .padding(.bottom, 5)
                                        .padding(.top, 5)
                                    
                                    Divider()
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.message.fill")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color(hex: "565dd9").gradient)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 4)

                    }
                    .padding()
                    .padding(.bottom, 50)
                }
            

            
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(postTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    PostDetailViewContentLoader(postTitle: "帖子详情", postID: "1", commentCount: 2)
//}
