//
//  LiangJianForumApp.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI
import BackgroundTasks

@main
struct FlarumiOSApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            LoginPageView()
                .environmentObject(appSettings)
        }
        .backgroundTask(.appRefresh("checkSessionAfterOneHour")) {
            scheduleAppRefresh()
            await refreshUser()
        }
        .backgroundTask(.urlSession("refreshUser")) {
            
        }
    }
    
    private func refreshUser() async {
        print("Refresh user token in Background...")
        print("user identification : \(appSettings.identification)")
        print("user password : \(appSettings.password)")
        
        let config = URLSessionConfiguration.background(withIdentifier: "refreshUser")
        config.sessionSendsLaunchEvents = true
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/token") else {
            print("Invalid URL!")
            return
        }
        
        let parameters: [String: String] = [
            "identification": appSettings.identification,
            "password": appSettings.password
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to convert username and password to JSON!")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let (data, _) = try? await session.data(for: request) {
            let decoder = JSONDecoder()
            do {
                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                appSettings.token = tokenResponse.token
                appSettings.userId = tokenResponse.userId
            } catch {
                print("Failed to decode token response: \(error)")
            }
        }
    }
}

func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "checkSessionAfterOneHour")
    // Fetch no earlier than about 1 hour from now.
    request.earliestBeginDate = Date(timeIntervalSinceNow: 55 * 60)
    
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Scheduled app refresh for one hour later.")
    } catch {
        print("Error scheduling app refresh: \(error)")
    }
}



