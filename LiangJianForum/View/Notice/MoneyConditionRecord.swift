//
//  MoneyConditionRecord.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/7.
//

import SwiftUI

struct MoneyConditionRecord: View {
    let Usermoney : Double?
    let userId : String
    
    @State private var moneyData = [Datum10]()
    @State private var money = -1.0
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack{
            if moneyData.isEmpty || money == -1.0{
                MoneyConditionRecordContentLoader()
            }else{
                List{
                    Section("当前资产"){
                        HStack{
                            Spacer()
                            
                            if Usermoney != nil{
                                if let usermoney = Usermoney{
                                    Text(String(usermoney))
                                        .font(Font.system(size: 60, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .tracking(0.5)
                                        .overlay {
                                            LinearGradient(
                                                colors: [.red, .blue, .green, .yellow],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .mask(
                                                Text(String(usermoney))
                                                    .font(Font.system(size: 60, weight: .bold))
                                                    .multilineTextAlignment(.center)
                                                    .tracking(0.5)
                                            )
                                        }
                                }
                            }else{
                                Text(String(money))
                                    .font(Font.system(size: 60, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .tracking(0.5)
                                    .overlay {
                                        LinearGradient(
                                            colors: [.red, .blue, .green, .yellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Text(String(money))
                                                .font(Font.system(size: 60, weight: .bold))
                                                .multilineTextAlignment(.center)
                                                .tracking(0.5)
                                        )
                                    }
                            }  
                            Spacer()
                        }
                    }
                    
                    Section("资产记录"){
                        ForEach(moneyData, id: \.id) { item in
                            HStack{
                                VStack(alignment: .leading){
                                    Text(item.attributes.createTime)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(translateReason(item.attributes.reason))
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .padding(.top)
                                }
                                
                                Spacer()
                                
                                Text(formatMoney(item.attributes.money))
                                    .bold()
                                    .font(.title)
                                    .foregroundStyle(item.attributes.money >= 0 ? .green : .red)
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
        }
        .navigationTitle("我的资产")
        .onAppear{
            Task{
                await fetchUserProfile()
            }
            
            fetchMoneyData { success in
                if success{
                    print("Successfully load MoneyRecord View!")
                }
            }
        }
        
    }
    
    func formatMoney(_ money: Double) -> String {
        let absoluteMoney = abs(money)
        let formattedMoney = money > 0 ? "+\(absoluteMoney)" : "-\(absoluteMoney)"
        return formattedMoney
    }

    func getShortenedReason(_ reason: String) -> String {
        if let range = reason.range(of: "xypp-money-more.forum.awarness.") {
            let startIndex = range.upperBound
            return String(reason[startIndex...])
        }
        return reason
    }
    
    func translateReason(_ reason: String) -> String {
        switch getShortenedReason(reason) {
        case "admin-edit":
            return "管理员修改"
        case "post-liked":
            return "回复被赞"
        case "discussion-started":
            return "发帖"
        case "bepurchased":
            return "付费内容收益"
        case "purchase":
            return "购买付费内容"
        case "checkin":
            return "签到"
        case "post-posted":
            return "评论"
        default:
            return "未知原因"
        }
    }
    
    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else{
                print("Invalid URL")
            return
        }
        print("Fetching User Info at: \(url)")
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                if let flarumMoney = decodedResponse.data.attributes.money{
                    self.money = flarumMoney
                }
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }
    
    private func fetchMoneyData(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/money-more/record/\(userId)?page=0") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        // 创建URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 使用GET方法
        
        // 设置请求头
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appSettings.token != "" {
            request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Invalid token or not logged in yet!")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                completion(false)
                return
            }
            
            // 在请求成功时处理数据
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(MoneyData.self, from: data) {
                    print("Successfully decoding use MoneyData.self")
                    self.moneyData = decodedResponse.data
                } else {
                    print("Decoding to MoneyData Failed!")
                }
            }
            
            // 请求成功后调用回调
            completion(true)
        }.resume()
    }
}
