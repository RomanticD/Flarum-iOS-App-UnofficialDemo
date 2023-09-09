//
//  CircleImage.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/18.
//

import SwiftUI

struct CircleImage: View {
    var image: Image
    var widthAndHeight: CGFloat
    var lineWidth: CGFloat
    var shadow: CGFloat
    var strokeColor: Color?
    
    var body: some View {
        if let color = strokeColor{
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: widthAndHeight, height: widthAndHeight)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(color, lineWidth: lineWidth)
                }
                .shadow(radius: shadow)
        }else{
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: widthAndHeight, height: widthAndHeight)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.white, lineWidth: lineWidth)
                }
                .shadow(radius: shadow)
        }
    }
}

public func loadImage(from urlString: String) -> Image {
    guard let url = URL(string: urlString), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
        return Image("Anya")
    }
    
    return Image(uiImage: image)
}

//struct CircleImage_Previews: PreviewProvider {
//    static var previews: some View {
//        CircleImage(image: loadImage(from: "https://hk.maxmc.cc/assets/avatars/T3TfVXzgpPqaGC8F.png"), widthAndHeight: 200, lineWidth: 4, shadow: 7)
//    }
//}

