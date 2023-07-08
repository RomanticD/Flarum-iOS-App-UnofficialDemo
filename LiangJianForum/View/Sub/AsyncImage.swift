//
//  ImageTest.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/29.
//

import SwiftUI

struct asyncImage: View {
    let url: URL?
    let frameSize: CGFloat
    let lineWidth: CGFloat
    let shadow: CGFloat
        
    init(url: URL?, frameSize: CGFloat, lineWidth: CGFloat, shadow: CGFloat) {
            self.url = url
            self.frameSize = frameSize
            self.lineWidth = lineWidth
            self.shadow = shadow
        }
    
    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: frameSize, height: frameSize)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(.white, lineWidth: lineWidth)
                        }
                        .shadow(radius: shadow)
                } placeholder: {
                    ProgressView()
                        .frame(width: frameSize, height: frameSize)
                }
            } else {
                ProgressView()
                    .frame(width: frameSize, height: frameSize)
            }
        }
    }
}


//#Preview {
//    asyncImage(url: URL(string: "https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/aef96ee1-3e73-4a60-b0eb-8f40e9ce1963"),frameSize: 70, lineWidth: 2, shadow: 5)
//}
