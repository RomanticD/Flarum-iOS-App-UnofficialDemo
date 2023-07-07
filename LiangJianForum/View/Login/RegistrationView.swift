//
//  RegistrationView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI

struct RegistrationView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var email = ""
    @State private var wrongUsername: CGFloat = 0
    @State private var wrongPassword: CGFloat  = 0
    @State private var wrongRepeatPassword: CGFloat  = 0
    @State private var wrongEmail: CGFloat  = 0
    @State private var registrationSuccess = false
    @State private var backToLoginPage = false
    @State private var isAnimating = false
    @State private var showingRegistrationView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var appSettings = AppSettings()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark{
                Color(hex: "0e1c26")
                    .ignoresSafeArea(.all, edges: .bottom)
            }else{
                Color.blue
                    .ignoresSafeArea(.all, edges: .bottom)
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
                Text("量见·注册")
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
                
                TextFieldWithIcon(iconName: "person.fill", inputText: $username, label: "用户名", isAnimating: $isAnimating, wrongInputRedBorder: $wrongUsername)
                
//                TextFieldWithIcon(iconName: "key.fill", inputText: $password, label: "密码", isAnimating: $isAnimating, wrongInputRedBorder: $wrongPassword)
                
                SecureFieldWithIcon(passwordIconName: "key.fill", inputPassword: $password , passwordLabel: "密码", isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongPassword)
                
//                TextFieldWithIcon(iconName: nil, inputText: $repeatPassword, label: "确认密码", isAnimating: $isAnimating, wrongInputRedBorder: $wrongRepeatPassword)
                
                SecureFieldWithIcon(passwordIconName: "nil", inputPassword: $repeatPassword , passwordLabel: "确认密码", isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongRepeatPassword)
                
                TextFieldWithIcon(iconName: "envelope.fill", inputText: $email, label: "邮箱", isAnimating: $isAnimating, wrongInputRedBorder: $wrongEmail)
                    .padding(.bottom)
                
                Button(action: { registrationVerification(username: username, password: password, repeatPassword: repeatPassword, email: email) }) {
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
                                clearFields()
                            }
                        )
                    } else {
                        return Alert(
                            title: Text("注册失败"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("确定")) {
                                clearFields()
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
    
    private func sendPostRequest() {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users") else {
                print("invalid Url!")
                return
            }
            
            let parameters: [String: String] = [
                "identification": username,
                "password": password
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
                print("Registration info to Json Failed!")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response")
                    return
                }
                
//                if let data = data {
//                            do {
//                                let decoder = JSONDecoder()
//                                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
//                                
//                                self.token = tokenResponse.token
//                                self.userId = tokenResponse.userId
//                            } catch {
//                                print("Error decoding JSON: \(error)")
//                            }
//                        }
            }.resume()
        }
    
    
    private func registrationVerification(username: String, password: String, repeatPassword: String, email: String) {
            var errors: [String] = []
            
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
                registrationSuccess = true
                showAlert(message: "验证邮件后才能发帖哦")
            } else {
                showAlert(message: errors.joined(separator: "\n"))
            }
        }
    
    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func clearFields() {
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

//#Preview {
//    RegistrationView()
//}

