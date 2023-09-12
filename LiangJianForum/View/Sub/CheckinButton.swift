//
//  CheckinButton.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/10.
//

import SwiftUI

struct CheckinButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings
    @Binding var isCheckInSucceeded : Bool
    
    
    var body: some View {
        Button {
            checkIn { success in
                if success{
                    isCheckInSucceeded = true
                    Task{
                        await fetchUserProfile()
                    }
                    print("successfully Check in !!!")
                }
            }
            
        } label: {
            Label(NSLocalizedString("check_in", comment: ""), systemImage: "flag.fill")
        }
        .disabled(isCheckInSucceeded || !appSettings.canCheckIn)
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
                appSettings.username = decodedResponse.data.attributes.username
                
                if let canCheckIn = decodedResponse.data.attributes.canCheckin{
                    appSettings.canCheckIn = canCheckIn
                }
                
                if let canCheckinContinuous = decodedResponse.data.attributes.canCheckinContinuous{
                    appSettings.canCheckinContinuous = canCheckinContinuous
                }
                
                if let totalContinuousCheckIn = decodedResponse.data.attributes.totalContinuousCheckIn{
                    appSettings.totalContinuousCheckIn = totalContinuousCheckIn
                }
                
                if let include = decodedResponse.included {
                    if include.contains(where: { $0.id == "1" }) {
                        appSettings.isAdmin = true
                    }
                }


                print("Successfully decoded user data when sign in success!")
                print("username : \(appSettings.username)")
                print("userId : \(appSettings.userId)")
                print("canCheckIn : \(appSettings.canCheckIn)")
                print("canCheckinContinuous : \(appSettings.canCheckinContinuous)")
                print("totalContinuousCheckIn : \(appSettings.totalContinuousCheckIn)")
                print("isAdmin : \(appSettings.isAdmin)")
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }
    
    
    private func checkIn(completion: @escaping (Bool) -> Void) {
        print("current Token: \(appSettings.token)")
        print("current FlarumUrl: \(appSettings.FlarumUrl)")
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else {
            print("invalid Url!")
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "users",
                "attributes": [
                    "canCheckin": false,
                    "totalContinuousCheckIn": appSettings.totalContinuousCheckIn
                ],
                "id": String(appSettings.userId)
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
}
