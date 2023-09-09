//
//  ContentView.swift
//  LiangJianF
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI

struct LoginPageView: View {
    @AppStorage("username") private var storedUsername = ""
    @AppStorage("password") private var storedPassword = ""
    @AppStorage("rememberMe") private var rememberMeState = false
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername: CGFloat = 0
    @State private var token = ""
    @State private var userId = 0
    @State private var wrongPassword: CGFloat  = 0
    @State private var showingMainPageView = false
    @State private var isAnimating = false
    @State private var showingRegistrationView = false
    @State private var showingProgressView = false
    @State private var rememberMe = false
    @State private var showAlert = false
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme
   
    var body: some View {
        NavigationView {
            ZStack {
                if colorScheme == .dark{
                    Color(hex: "0e1c26")
                        .ignoresSafeArea()
                }else{
                    Color.blue
                        .ignoresSafeArea()
                }
                
                
                Circle()
                    .scaleEffect(isAnimating ? 1.7 : 0.3)
                        .animation(.easeInOut(duration: 0.6), value: isAnimating)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scaleEffect(isAnimating ? 1.35 : 0)
                        .animation(.easeInOut(duration: 1), value: isAnimating)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "294861") : .white)

                VStack {
                    Text(appSettings.FlarumName)
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                        .padding(.bottom, 30)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: isAnimating)
                        .onAppear {
                            withAnimation {
                                isAnimating = true
                            }

                        }
                  
                    TextFieldWithIcon(iconName: "person.fill", inputText: $username, label: NSLocalizedString("username", comment: ""), isAnimating: $isAnimating, wrongInputRedBorder: $wrongUsername)
                    .onAppear {
                        username = storedUsername
                    }
                    
                    SecureFieldWithIcon(passwordIconName: "key.fill", inputPassword: $password , passwordLabel: NSLocalizedString("password", comment: ""), isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongPassword)
                        .padding(.bottom)
                    .onAppear {
                        password = storedPassword
                    }

                    Button(action: {
                        authenticateUser { success in
                            if success {
                                // 登录成功后的操作
                            } else {
                                showAlert.toggle()
                            }
                        }
                    }) {
                        Text("Sign in")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 350, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .opacity(isAnimating ? 0.9 : 0)
                    .animation(.easeInOut(duration: 1.5), value: isAnimating)
                    .onDisappear {
                        storedUsername = username
                        storedPassword = password
                    }
                    
                    NavigationLink(destination: ContentView().environmentObject(appSettings).navigationBarBackButtonHidden(true), isActive: $showingMainPageView) {
                    }
                    .onTapGesture {
                        if !showingMainPageView{
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        }
                    }
                    
                    if showingProgressView{
                        ProgressView()
                            .padding(.top)
                    }

                    ZStack{
                        Button(action: {showingRegistrationView = true}) {
                                Text("Sign up")
                                .fontWeight(.bold)
                            }
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                        .frame(width: 330, height: 50)
                        .cornerRadius(10)
                        .opacity(isAnimating ? 0.8 : 0)
                        .animation(.easeInOut(duration: 1.5), value: isAnimating)
                      
                        NavigationLink(destination: RegistrationView().environmentObject(appSettings).navigationBarBackButtonHidden(false), isActive: .constant(false)) {
                        }// Need Your api Key to access the Sign up page
                        
                        HStack {
                            Spacer()
                            Toggle(isOn: $rememberMe){
                                Text("Remember Me")
                                    .font(.system(size: 15))
                                    .opacity(0.8)
                            }
                            .toggleStyle(.button)
                            .tint(.mint)
                            .padding(.trailing, 20)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.easeInOut(duration: 1.5), value: isAnimating)
                            .onAppear {
                                rememberMe = rememberMeState
                            }
                        }
                    }
                    
                    
                    
//                    VStack {
//                        Text("**服务条款** ｜ **[隐私政策](https://www.apple.com/legal/privacy/szh/)**").font(.system(size: 10))
//                            .animation(.easeInOut(duration: 1.5), value: isAnimating)
//                    }
//                    .frame(width: 350)
//                    .padding(.top)
                }
                .navigationTitle("Sign in")
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Failed to sign in"),
                        message: Text("Please check your username/password or check the Internet connetction"),
                        dismissButton: .default(Text("OK")) {
                            clearInputField()
                        }
                    )
                }
            }.navigationBarHidden(true)
        }
    }

    private func clearInputField(){
        wrongUsername = 0
        wrongPassword = 0
        password = ""
        username = ""
        storedPassword = ""
        storedUsername = ""
    }
    
    private func authenticateUser(completion: @escaping (Bool) -> Void) {
        showingProgressView = true
        sendPostRequest { success in
            showingProgressView = false
            
            if success, token != "", userId != 0 {
                wrongUsername = 0
                wrongPassword = 0
                showingMainPageView = true
                appSettings.isLoggedIn = true
                appSettings.token = token
                appSettings.userId = userId
                if rememberMe{
                    rememberMeState = true
                }else{
                    clearInputField()
                    rememberMeState = false
                }
                
                print("Token: \(appSettings.token)")
                print("User ID: \(appSettings.userId)")
                
                completion(true) // Authentication success
            } else {
                wrongUsername = 2
                wrongPassword = 2
                
                completion(false) // Authentication failed
            }
        }
    }

    private func sendPostRequest(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/token") else {
            print("Invalid URL!")
            completion(false)
            return
        }
        
        let parameters: [String: String] = [
            "identification": username,
            "password": password
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to convert username and password to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let startTime = Date().timeIntervalSince1970
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let elapsedTime = Date().timeIntervalSince1970 - startTime
            
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response from post /api/token")
                completion(false)
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                    
                    self.token = tokenResponse.token
                    self.userId = tokenResponse.userId
                    
                    completion(true) // Authentication success
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }.resume()
    }

}

struct TokenResponse: Codable {
    let token: String
    let userId: Int
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPageView().environmentObject(AppSettings())
//    }
//}

