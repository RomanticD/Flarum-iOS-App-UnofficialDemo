//
//  LinksProfileView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/4.
//

import SwiftUI

struct LinksProfileView: View {
    let userId: Int
    
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var avatarUrl: String = ""
    @State private var joinTime: String = ""
    @State private var lastSeenAt: String = ""
    @State private var discussionCount: Int = 0
    @State private var commentCount: Int = 0
    @State private var money: Double = -1
    @State private var include: [UserInclude]?
    @State private var savePersonalProfile = false
    @State private var selectedRow: Int? = nil
    @State private var newNickName: String = ""
    @State private var newIntroduction: String = ""
    @AppStorage("nickName") var nickName: String = ""
    @AppStorage("introduction") var introduction: String = ""
    @State private var showAlert = false
    @State private var showSaveAlert = false
    @State private var showLogoutAlert = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings
    @State private var showLoginPage = false
    @State private var buttonText = "保存"
    @State private var searchTerm = ""
    @State private var currentPageOffset = 0
    @State private var userCommentData = [Datum8]()
    @State private var userCommentInclude = [Included8]()
    @State private var hasNextPage = false
    @State private var hasPrevPage = false

    private var isUserVIP: Bool {
        return appSettings.vipUsernames.contains(username)
    }
    
    var body: some View {
        VStack{
            HStack{
                if avatarUrl != "" {
                    if isUserVIP{
                        AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 130, lineWidth: 2.5, shadow: 6, strokeColor : Color(hex: "FFD700"))
                            .padding(.bottom)
                    }else{
                        AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 130, lineWidth: 2, shadow: 6)
                            .padding(.bottom)
                    }
                } else {
                    CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 120, lineWidth: 1, shadow: 3)
                        .opacity (0.3)
                        .padding(.bottom)
                }

            }
            List{
                Section{
                    HStack {
                        Text("🎊 Username: ").foregroundStyle(.secondary)
                        Text("\(username)").bold()
                    }
                    HStack {
                        Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                        Text("\(displayName)").bold()
                    }
                    HStack {
                        Text("🎉 Join Time:").foregroundStyle(.secondary)
                        Text("\(joinTime)").bold()
                    }
                    HStack{
                        Text("🎀 Last seen at:").foregroundStyle(.secondary)
                        if lastSeenAt.isEmpty{
                            Text("Information has been hidden")
                                .bold()
                        }else{
                            Text("\(lastSeenAt)").bold()
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section("Flarum Contributions"){
                    HStack {
                        Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                        Text("\(discussionCount)").bold()
                    }
                    
                    HStack{
                        NavigationLink(value: commentCount){
                            Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                            Text("\(commentCount)").bold()
                        }
                    }
                    .navigationDestination(for: Int.self) { number in
                        CommentsView(username: username, displayname: displayName, userCommentData: $userCommentData, userCommentInclude: $userCommentInclude, avatarUrl: avatarUrl, searchTerm: $searchTerm)
                    }
                    
                    
                    if self.money != -1 {
                        HStack {
                            NavigationLink(value: money){
                                Text("💰 money: ").foregroundStyle(.secondary)
                                if self.money.truncatingRemainder(dividingBy: 1) == 0 {
                                    Text(String(format: "%.0f", self.money)).bold()
                                } else {
                                    Text(String(format: "%.1f", self.money)).bold()
                                }
                            }
                        }
                        .navigationDestination(for: Double.self) { number in
                            MoneyConditionRecord(Usermoney: self.money, userId: String(userId))
                        }
                    }
                }
                
                Section("Authentication Information") {
                    if let include = include, !include.isEmpty {
                        let groups = include.filter { $0.type == "groups" }
                        if !groups.isEmpty {
                            ForEach(groups, id: \.id) { item in
                                HStack{
                                    if let singular = item.attributes.nameSingular {
                                        Text("✅ \(singular): ").foregroundStyle(.secondary)
                                    }

                                    if let plural = item.attributes.namePlural {
                                        Text("\(plural)").bold()
                                    }
                                }
                            }
                        } else {
                            Text("No authentication information available")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    } else {
                        Text("No authentication information available")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Section("Earned Badges") {
                    if let include = include, !include.isEmpty {
                        let groups = include.filter { $0.type == "badges" }
                        if !groups.isEmpty {
                            ForEach(groups, id: \.id) { item in
                                HStack{
                                    if let badgeName = item.attributes.name {
                                        Text("🎖️ \(badgeName): ").foregroundStyle(.secondary)
                                    }

                                    if let badgeDescription = item.attributes.description {
                                        Text("\(badgeDescription)").bold()
                                    }
                                }
                            }
                        } else {
                            Text("No Badges Earned Yet")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    } else {
                        Text("No Badges Earned Yet")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .textSelection(.enabled)
        }
        .navigationTitle("\(self.displayName)的主页")
        .task{
            await fetchOtherUserProfile()
            await fetchOtherUserPost()
        }
//        .alert(isPresented: $showLogoutAlert) {
//            Alert(
//                title: Text("Sign out"),
//                message: Text("Quit?"),
//                primaryButton: .default(Text("Confirm"), action: {
//                    logoutConfirmed()
//                }),
//                secondaryButton: .cancel(Text("Cancel"))
//            )
//        }
        .refreshable {
            await fetchOtherUserProfile()
        }
        .onAppear {
            newIntroduction = introduction
            newNickName = nickName
            Task{
                await fetchOtherUserPost()
            }
        }
        .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
        
    }

//    func saveProfile() {
//            showAlert = true
//            savePersonalProfile = true
//            showSaveAlert = true
//            nickName = newNickName
//            introduction = newIntroduction
//            
//            buttonText = "保存成功!"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                buttonText = "保存"
//                savePersonalProfile = false
//            }
//        }

//    func logoutConfirmed() {
//        appSettings.token = ""
//        showLoginPage.toggle()
//        appSettings.isLoggedIn = false
//    }
//    
//    
//    func logout() {
//        showAlert = true
//        showLogoutAlert = true
//    }
    
    private func fetchOtherUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(self.userId)") else{
                print("Invalid URL")
            return
        }
        print("Fetching User Info : at: \(url)")
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                if let includes = decodedResponse.included{
                    self.include = includes
                }
                self.username = decodedResponse.data.attributes.username
                self.displayName = decodedResponse.data.attributes.displayName
                
                if let avatar = decodedResponse.data.attributes.avatarURL{
                    self.avatarUrl = avatar
                }
                self.joinTime = calculateTimeDifference(from: decodedResponse.data.attributes.joinTime)
                if let hasLastSeenTime = decodedResponse.data.attributes.lastSeenAt{
                    self.lastSeenAt = calculateTimeDifference(from: hasLastSeenTime)
                }
//                self.lastSeenAt =  calculateTimeDifference(from: decodedResponse.data.attributes.lastSeenAt)
                self.discussionCount = decodedResponse.data.attributes.discussionCount
                self.commentCount = decodedResponse.data.attributes.commentCount
                
                if let flarumMoney = decodedResponse.data.attributes.money{
                    self.money = flarumMoney
                }

                print("Successfully decoded user data")
                print("Username: \(self.username)")
                print("Display Name: \(self.displayName)")
                print("Avatar URL: \(self.avatarUrl)")
                print("Join Time: \(self.joinTime)")
                print("Last Seen At: \(self.lastSeenAt)")
                print("Discussion Count: \(self.discussionCount)")
                print("Comment Count: \(self.commentCount)")
                print("money: \(self.money)")
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }

    private func isLoginUseProfile() -> Bool{
        return self.userId == appSettings.userId
    }
    
    private func fetchOtherUserPost() async {

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
            print("Invalid URL")
            return
        }

        do{
           print("fetching from \(url)")
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                print("successfully decode \(username)'s comment data")
                print("current page offset: \(currentPageOffset)")
                print("has next page: \(hasNextPage)")
                print("has prev page: \(hasPrevPage)")
            }else{
                print("fetching user \(username) 's comments data failed")
            }

        } catch {
            print("Invalid user's comment Data!" ,error)
        }
    }
}

