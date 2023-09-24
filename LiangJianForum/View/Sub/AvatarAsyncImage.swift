//
//  ImageTest.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/29.
//

import SwiftUI

struct AvatarAsyncImage: View {
    let url: URL?
    let frameSize: CGFloat
    let lineWidth: CGFloat
    let shadow: CGFloat
    var strokeColor: Color?
        
    init(url: URL?, frameSize: CGFloat, lineWidth: CGFloat, shadow: CGFloat, strokeColor: Color? = nil) {
        self.url = url
        self.frameSize = frameSize
        self.lineWidth = lineWidth
        self.shadow = shadow
        self.strokeColor = strokeColor
    }

    
    var body: some View {
        Group {
            if let url = url {
                if let color = strokeColor{
//                    AsyncImage(url: url) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: frameSize, height: frameSize)
//                            .clipShape(Circle())
//                            .overlay {
//                                Circle().stroke(color, lineWidth: lineWidth)
//                            }
//                            .shadow(radius: shadow)
//                    } placeholder: {
//                        ShimmerEffectBox()
//                            .frame(width: frameSize, height: frameSize)
//                            .cornerRadius(frameSize / 2)
//                    }
                    
                    CachedImage(url: url.absoluteString,
                                animation: .spring(),
                                transition: .scale.combined(with: .opacity)) { phase in
                        
                        switch phase {
                        case .empty:
                            ShimmerEffectBox()
                                .frame(width: frameSize, height: frameSize)
                                .cornerRadius(frameSize / 2)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: frameSize, height: frameSize)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(color, lineWidth: lineWidth)
                                }
                                .shadow(radius: shadow)
                            
                        case .failure(let error):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }else{
                    CachedImage(url: url.absoluteString,
                                animation: .spring(),
                                transition: .scale.combined(with: .opacity)) { phase in
                        
                        switch phase {
                        case .empty:
                            ShimmerEffectBox()
                                .frame(width: frameSize, height: frameSize)
                                .cornerRadius(frameSize / 2)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: frameSize, height: frameSize)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(.white, lineWidth: lineWidth)
                                }
                                .shadow(radius: shadow)
                            
                        case .failure(let error):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            } else {
                ShimmerEffectBox()
                    .frame(width: frameSize, height: frameSize)
                    .cornerRadius(frameSize / 2)
            }
        }
    }
}
