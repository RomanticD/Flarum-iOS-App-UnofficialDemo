//
//  RegistrationView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI

struct RegistrationView: View {
    @State private var username = ""
    @State private var displayname = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var email = ""
    @State private var wrongUsername: CGFloat = 0
    @State private var wrongDisplayrname: CGFloat = 0
    @State private var wrongPassword: CGFloat  = 0
    @State private var wrongRepeatPassword: CGFloat  = 0
    @State private var wrongEmail: CGFloat  = 0
    @State private var registrationSuccess = false
    @State private var backToLoginPage = false
    @State private var isAnimating = false
    @State private var showingRegistrationView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var errors: [String] = []
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark{
                Color(hex: "134780")
                    .ignoresSafeArea(.all, edges: .bottom)
            }else{
                Color.blue
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            
            Circle()
                .scaleEffect(isAnimating ? 1.7 : 0.3)
                    .animation(.easeInOut(duration: 0.6), value: isAnimating)
                    .foregroundColor(colorScheme == .dark ? Color(hex: "0f3966") : Color(hex: "258eff"))
            
            Circle()
                .scaleEffect(isAnimating ? 1.35 : 0)
                    .animation(.easeInOut(duration: 1), value: isAnimating)
                    .foregroundColor(colorScheme == .dark ? Color(hex: "0b2b4d") : Color(hex: "d3e8ff"))
            
            VStack {
                Text("\(appSettings.FlarumName)·注册")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                    .padding(.bottom, 30)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: isAnimating)
                    .onAppear {
                        withAnimation {
                            isAnimating = true
                        }
                    }
                
                TextFieldWithIcon(iconName: "person.fill", inputText: $username, label: "用户名(登录用 数字或字母组合)", isAnimating: $isAnimating, wrongInputRedBorder: $wrongUsername)
                
//                TextFieldWithIcon(iconName: "person.crop.square.filled.and.at.rectangle", inputText: $displayname, label: "昵称(对外显示)", isAnimating: $isAnimating, wrongInputRedBorder: $wrongDisplayrname)
                
                SecureFieldWithIcon(passwordIconName: "key.fill", inputPassword: $password , passwordLabel: "密码", isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongPassword)
           
                SecureFieldWithIcon(passwordIconName: nil, inputPassword: $repeatPassword , passwordLabel: "确认密码", isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongRepeatPassword)
                
                TextFieldWithIcon(iconName: "envelope.fill", inputText: $email, label: "邮箱", isAnimating: $isAnimating, wrongInputRedBorder: $wrongEmail)
                    .padding(.bottom)
                
                Button(action: {
                    clearErrorMessage()
                    let vertificationResult = registrationVerification(username: username, password: password, repeatPassword: repeatPassword, email: email)
                    sendRegistrationRequest(inputFieldValid: vertificationResult) { success in
                        if success{
                            registrationSuccess = true
                            showAlert(message: "注册成功，请及时完成邮件及统一平台认证")
                        }else{
                            showAlert(message: errors.joined(separator: "\n"))
                        }
                    }
                }) {
                    Text("注册")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(width: 350, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .opacity(isAnimating ? 0.9 : 0)
                .animation(.easeInOut(duration: 1.5), value: isAnimating)
                .alert(isPresented: $showAlert) {
                    if registrationSuccess {
                        return Alert(
                            title: Text("注册成功，即将返回登录页"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("确定")) {
                                backToLoginPage = true
//                                clearFields()
                            }
                        )
                    } else {
                        return Alert(
                            title: Text("注册失败"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("确定")) {
//                                clearFields()
                            }
                        )
                    }
                }


                NavigationLink(destination: LoginPageView().navigationBarBackButtonHidden(true), isActive: $backToLoginPage) {}
                
                VStack {
                    Text("**服务条款** 和 **[隐私政策](https://www.apple.com/legal/privacy/szh/)**").font(.system(size: 12))
                        .animation(.easeInOut(duration: 1.5), value: isAnimating)
                }
                .frame(width: 350)
                .padding(.top)
                
            }
        }
    }
    
    private func sendRegistrationRequest(inputFieldValid: Bool, completion: @escaping (Bool) -> Void) {
        if !inputFieldValid {
            completion(false)
        }
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users") else {
            print("Invalid URL!")
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "attributes": [
                    "username": username,
                    "email": email,
                    "password": password
                ]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to convert registraton info to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(appSettings.FlarumToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(RegistrationResponse.self, from: data)
                    
                    if response.errors == nil{
                        //registration succeeded
                        completion(true)
                    }else{
                        if let errorInfo = response.errors{
                            for errorMessage in errorInfo{
                                self.errors.append(errorMessage.detail)
                            }
                        }
                    }
                    
                    completion(false)
                } catch {
                    print("Error decoding JSON when decoding RegistrationResponse")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }.resume()
    }
    
    
    private func registrationVerification(username: String, password: String, repeatPassword: String, email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            let isEmailValid = emailPredicate.evaluate(with: email)
            
            if username.isEmpty {
                errors.append("请输入用户名")
                wrongUsername = 2
            }
            
            if password.isEmpty {
                errors.append("请输入密码")
                wrongPassword = 2
            }
            
            if repeatPassword != password && !password.isEmpty{
                errors.append("两次输入的密码不匹配")
                wrongPassword = 2
                wrongRepeatPassword = 2
            }
            
            if !isEmailValid {
                errors.append("请输入有效的邮箱地址")
                wrongEmail = 2
            }
            
            if errors.isEmpty {
                return true
            }
        
            return false
        }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func clearErrorMessage(){
        self.errors = []
    }
    
    private func clearFields() {
        if wrongUsername != 0 {
            username = ""
        }
        
        if wrongPassword != 0 {
            password = ""
        }
        
        if wrongRepeatPassword != 0 {
            repeatPassword = ""
        }
        
        if wrongEmail != 0 {
            email = ""
        }
        
        wrongUsername = 0
        wrongPassword = 0
        wrongRepeatPassword = 0
        wrongEmail = 0
    }

}

// MARK: - RegistrationResponse
struct RegistrationResponse: Codable {
    let errors: [RegistrationError]?
}

// MARK: - Error
struct RegistrationError: Codable {
    let status, code, detail: String
    let source: RegistrationErrorSource
}

// MARK: - Source
struct RegistrationErrorSource: Codable {
    let pointer: String
}
