//
//  PollChartView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/31.
//

import SwiftUI
import Charts

struct PollChartView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var pollOptionsAndVoteCount: [String: Int]
    var AnswerWithId: [String: String]
    var voteQuestion: String?
    var endDate: String?
    var createdAT: String?
    var canVote: Bool?
    var pollId: String
    var allowMultipleVotes: Bool?
    var maxVotes: Int?
    var allowChangeVote: Bool?
    
    @State private var selectedOptionIds: [String] = []
    @State private var selectedOptions: [String] = []
    @State private var isLoading = false
    @State private var isVotingComplete = false
    @State private var isPollChartVisible = true

    
    var body: some View {
        if let voteTitle = voteQuestion{
            GroupBox{
                Text(voteTitle)
                    .bold()
                    .font(.system(size: 15))
                    .padding(.leading)
                
                Chart{
                    ForEach(pollOptionsAndVoteCount.sorted(by: { $0.key < $1.key }), id: \.key) { answer, voteCount in
                        BarMark(
                            x: .value("投票数", voteCount),
                            y: .value("选项名", answer)
                        )
                        .foregroundStyle(by: .value("选项名", answer))
                    }
                }
                .chartLegend(.hidden)
                .frame(height: CGFloat(pollOptionsAndVoteCount.count * 80))
                .padding(.bottom)
                .padding(.leading)
                .padding(.trailing)
                .chartXAxis {
                    AxisMarks(
                        preset: .aligned,
                        position: .bottom
                    )
                }
                .chartXScale(domain: 0...Int(Double(findMaxVoteCount()) * 1.3 + 1))
                
                //允许选择选项
                HStack{
                    Image(systemName: "rectangle.on.rectangle.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if let allowMultiOptions = allowMultipleVotes {
                        if allowMultiOptions{
                            if let maxOption = maxVotes {
                                if maxOption == 0 {
                                    Text("允许用户选择多个选项")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    
                                } else {
                                    Text("允许用户选择 \(maxOption) 个选项")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text("允许用户选择 1 个选项")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
                .padding(.trailing)
                
                //是否可修改选择
                HStack{
                    Image(systemName: "checkmark.gobackward")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if let canChange = allowChangeVote {
                        if canChange{
                            Text("可修改选择")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        } else {
                            Text("不可修改选择")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 3)
                .padding(.leading)
                .padding(.trailing)
                
                //截止时间
                HStack{
                    if let endDate = endDate{
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        if isBeforeEndDate(endDate: endDate) {
                            Text("已结束")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        } else {
                            Text("将于 \(calculateTimeDifference(to: endDate)) 结束")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 3)
                .padding(.leading)
                .padding(.trailing)
                
                //投票界面
                VStack{
                    if displayVotingArea() && isPollChartVisible{
                        ForEach(pollOptionsAndVoteCount.sorted(by: { $0.key < $1.key }), id: \.key) { answer, voteCount in
                                Toggle(isOn: Binding(
                                    get: {
                                        self.selectedOptions.contains(answer)
                                    },
                                    set: {
                                        if $0 {
                                            self.selectedOptions.append(answer)
                                        } else {
                                            self.selectedOptions.removeAll { $0 == answer }
                                        }
                                    }
                                )) {
                                    Text(answer)
                                        .font(.system(size: 15))
                                        .bold()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .tracking(0.5)
                                        .lineSpacing(7)
                                }
                                .padding(.leading)
                                .padding(.trailing)
                                .padding(.top, 3)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "565dd9")))
                            }
                        
                        HStack {
                            Button(action: completeVoting) {
                                HStack {
                                    Text("投票")
                                        .bold()
                                    
                                    if isLoading{
                                        ProgressView()
                                            .padding(.leading)
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color(hex: "565dd9"))
                            .cornerRadius(10)
                            .padding(.top)
                        }
                    }
                }
                .padding(.top)
                .onAppear {
                    // 检查当前用户是否已完成投票
                    if let completedVotes = appSettings.completedVotes[appSettings.userId], completedVotes.contains(pollId) {
                        if let canChage = allowChangeVote{
                            if canChage == false {
                                isPollChartVisible = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func displayVotingArea() -> Bool {
            // 检查是否不允许修改选择
        if let canChage = allowChangeVote{
            if canChage == true {
                return true
            }
        }
        
        // 检查是否已完成投票
        if let completedVotes = appSettings.completedVotes[appSettings.userId] {
            if completedVotes.contains(pollId) {
                return false // 如果已完成投票，返回 false 以禁用投票界面
            }
        }

        // 检查是否已过截止时间
        if let endDate = endDate {
            if !isBeforeEndDate(endDate: endDate) {
                return true // 如果尚未过截止时间，返回 true 以显示投票界面
            }
        } else {
            return true // 如果没有截止时间，始终显示投票界面
        }

        return false
    }
    
    // Function to check if the endDate is before the current date
    private func isBeforeEndDate(endDate: String) -> Bool {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: endDate) else {
            return false // Handle invalid date format as needed
        }
        
        let currentTime = Date()
        return date < currentTime
    }
    
    private func findMaxVoteCount() -> Int {
        var maxVoteCount = 0
        
        for (_, voteCount) in pollOptionsAndVoteCount {
            if voteCount > maxVoteCount {
                maxVoteCount = voteCount
            }
        }
        
        return maxVoteCount
    }
    
    private func completeVoting() {
            isLoading = true

            processOptionIdInRequest()

            sendVoteRequest { success in
                if success {
                    appSettings.refreshComment()
                    print("success")
                    isLoading = false

                    // 设置投票完成标志
                    isVotingComplete = true

                    // 保存已完成投票的帖子ID
                    var completedVotes = appSettings.completedVotes[appSettings.userId] ?? []
                    completedVotes.append(pollId)
                    appSettings.completedVotes[appSettings.userId] = completedVotes
                    
                } else {
                    print("failed")
                    isLoading = false
                }
            }
        }
    
    private func sendVoteRequest(completion: @escaping (Bool) -> Void) {
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/fof/polls/\(pollId)/votes") else {
            print("invalid Url!")
            completion(false)
            return
        }

        let parameters: [String: Any] = [
            "data": [
                "optionIds": self.selectedOptionIds
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize post data to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appSettings.token != ""{
            request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
        }else{
            print("Invalid Token Or Not Logged in Yet!")
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
            
            completion(true)
        }.resume()
    }

    private func processOptionIdInRequest() {
        selectedOptionIds = []
        
        for selectedOption in selectedOptions {
            if let optionId = AnswerWithId[selectedOption] {
                selectedOptionIds.append(optionId)
            }
        }
    }

}
