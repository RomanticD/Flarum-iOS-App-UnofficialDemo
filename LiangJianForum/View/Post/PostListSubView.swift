import SwiftUI

struct PostListSubView: View {
    let item: Included5
    let colorScheme: ColorScheme
    let bestAnswerID: String
    let usersArrayTags: [Included5] // Pass the usersArrayTags as a parameter

    var body: some View {
        HStack {
            UserAvatarView(item: item, usersArrayTags: usersArrayTags, colorScheme: colorScheme) // Pass usersArrayTags
            PostContentView(item: item, usersArrayTags: usersArrayTags, bestAnswerID: bestAnswerID) // Pass usersArrayTags
        }
        .background(item.id == bestAnswerID ? Color.green.opacity(0.2) : Color.clear)
        .cornerRadius(5)
    }
}

struct UserAvatarView: View {
    let item: Included5
    let colorScheme: ColorScheme
    let usersArrayTags: [Included5] // Pass the usersArrayTags as a parameter

    var body: some View {
        VStack {
            if let userid = item.relationships?.user?.data.id {
                if let avatarURL = findImgUrl(userid, in: usersArrayTags) {
                    asyncImage(url: URL(string: avatarURL), frameSize: 50, lineWidth: 1, shadow: 3)
                        .padding(.top, 10)
                } else {
                    CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
                        .opacity(0.3)
                        .padding(.top, 10)
                }
            }
            Spacer()
        }
    }
}

struct PostContentView: View {
    let item: Included5
    let bestAnswerID: String
    let usersArrayTags: [Included5] // Pass the usersArrayTags as a parameter

    var body: some View {
        VStack {
            HStack {
                if let userid = item.relationships?.user?.data.id {
                    if let displayName = findDisplayName(userid, in: usersArrayTags) { // Use findDisplayName from parameters
                        Text(displayName)
                            .font(.system(size: 12))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.leading, 3)
                    }
                } else {
                    ProgressView()
                }

                // Add other user-related information here

                Spacer()

                if item.id == bestAnswerID {
                    Text("Best Answer")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }

            HStack {
                if let content = item.attributes.contentHTML {
                    Text(content.htmlConvertedWithoutUrl)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                        .padding(.top)
                        .padding(.leading, 3)
                        .font(.system(size: 15))
                } else {
                    Text("unsupported")
                        .foregroundColor(.gray)
                        .padding(.top)
                        .padding(.leading, 3)
                        .font(.system(size: 20))
                        .opacity(0.5)
                }
                Spacer()
            }

            if let includeImgReply = item.attributes.contentHTML {
                if let imageUrls = extractImageURLs(from: includeImgReply) {
                    ForEach(imageUrls, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 215)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .overlay(Rectangle()
                                    .stroke(.white, lineWidth: 1)
                                    .cornerRadius(10))
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}

