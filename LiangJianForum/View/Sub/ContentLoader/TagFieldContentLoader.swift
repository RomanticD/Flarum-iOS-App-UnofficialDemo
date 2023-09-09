//
//  TabFieldContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/6.
//

import SwiftUI

struct TagFieldContentLoader: View {
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(0..<15) { item in
                    NavigationLink(value: item){
                        HStack {
                            HStack {
                                ShimmerEffectBox()
                                    .frame(width: 20, height: 20)
                                
                                ShimmerEffectBox()
                                    .frame(width: 80, height: 20)
                                    .padding(.leading, 5)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    }
                }
            }
            .navigationTitle("All Tags")
            }
    }
}

//#Preview {
//    TagFieldContentLoader()
//}
