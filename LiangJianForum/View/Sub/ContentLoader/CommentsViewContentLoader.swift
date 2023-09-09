//
//  NoticeViewContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/6.
//

import SwiftUI

struct CommentsViewContentLoader: View {
    var body: some View {
        NavigationStack{
            ScrollViewReader{ proxy in
                VStack{
                    List{
                        ForEach(0..<8) { item in
                            let sectionTitle = NSLocalizedString("     ", comment: "") + " " + "   " + " "
   
                            Section(sectionTitle){
                                NavigationLink(value: item){
                                    VStack{
                                        HStack{
                                            ShimmerEffectBox()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(25)
                                            
                                            ShimmerEffectBox()
                                                .frame(height: 12)
                                                .cornerRadius(2)
                                            
                                            Spacer()
                                        }
                                        
                                        ShimmerEffectBox()
                                            .frame(height: 75)
                                            .cornerRadius(5)
                                            .padding(.top)
                                    }
                                }
                            }
                        }
                        .id("AllUserComments")
                    }
                    .navigationTitle("Notification Center")
                }
                .id("Top")
                .navigationTitle("Notification Center")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

//#Preview {
//    CommentsViewContentLoader()
//}
