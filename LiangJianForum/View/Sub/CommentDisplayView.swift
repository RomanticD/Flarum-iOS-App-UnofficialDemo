//
//  CommentDisplayView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/3.
//

import SwiftUI

struct CommentDisplayView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    @Binding var copiedText: String?
    var contentHTML: String?
    @State private var isButtonClicked = "No"
    @State private var price = 0
    @State private var payedNumber = 0
  
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if let content = contentHTML {
                let isPostMention = content.contains("class=\"PostMention\" data-id=\"")
                let isPaymentRequired = content.contains("ptr-block ptr-render ptr-payment-require")
                
                if isPaymentRequired, let price = getPriceFromContent(contentHTML: contentHTML), let payedNumber = getPayedNumberFromContent(contentHTML: contentHTML){
                    VStack{
                        HStack{
                            Spacer()
                            
                            Text("包含付费内容 价值\(price)量见币 \(payedNumber)人购买")
                                .bold()
                                .tracking(0.5)
                                .lineSpacing(7)
                                .foregroundColor(Color("FlarumTheme"))
                                .padding(.top)
                                .font(.system(size: 15))
                                .padding(.leading, 3)
                            Spacer()
                        }

                        HStack{
                            if isPostMention {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.mint)
                                    .padding(.top)
                                    .padding(.leading, 3)
                            }
                            
                            Text(LocalizedStringKey(content.htmlConvertedWithoutUrl))
                                .tracking(0.5)
                                .lineSpacing(7)
                                .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                                .padding(.top)
                                .font(.system(size: 15))
                                .padding(.leading, isPostMention ? 0 : 3)
                        }
                    }
                    
                }else{
                    if isPostMention {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.mint)
                            .padding(.top)
                            .padding(.leading, 3)
                    }
                    
                    Text(LocalizedStringKey(content.htmlConvertedWithoutUrl))
                        .tracking(0.5)
                        .lineSpacing(7)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                        .padding(.top)
                        .font(.system(size: 15))
                        .padding(.leading, isPostMention ? 0 : 3)
                }
            }else{
                Text("unsupported")
                    .foregroundColor(.gray)
                    .padding(.top)
                    .padding(.leading, 3)
                    .font(.system(size: 10))
                    .opacity(0.5)
            }
            Spacer()
        }
        .contextMenu {
            Button(action: {
                if let content = contentHTML{
                    copyTextToClipboard(content.htmlConvertedWithoutUrl)
                }
            }) {
                Label(NSLocalizedString("copy_in_contextMenu", comment: ""), systemImage: "doc.on.clipboard")
            }
            
            if let content = contentHTML {
                if content.contains("ptr-block ptr-render ptr-payment-require"){
                    Button(action: {
                        if let paymentId = getPaymentId(contentHTML: contentHTML){
                            payToRead(paymentId: paymentId){success in
                                if success{
                                    print("Successfully Paid!")
                                    appSettings.refreshComment()
                                }
                            }
                        }
                    }) {
                        Label("pay_to_read_message", systemImage: "dollarsign.square")
                    }
                }
            }
        }
        
        if let includeImgReply = contentHTML{
            if let imageUrls = extractImageURLs(from: includeImgReply){
                ForEach(imageUrls, id: \.self) { url in
                    CachedImage(url: url,
                                animation: .spring(),
                                transition: AnyTransition.opacity.animation(.easeInOut)) { phase in
                        
                        switch phase {
                        case .empty:
                            ShimmerEffectBox()
                                .frame(width: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .padding(.bottom)
                            
                        case .failure(let error):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .onTapGesture {
                        if let imgurl = URL(string: url) {
                            UIApplication.shared.open(imgurl)
                        }
                    }
                }
            }
        }
    }
    
    private func copyTextToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        copiedText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copiedText = nil
        }
    }
    
    private func getPriceFromContent(contentHTML: String?) -> Int? {
        if let content = contentHTML{
            let regex = try? NSRegularExpression(pattern: #"data-ammount="(\d+)"#)
            if let match = regex?.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) {
                if let range = Range(match.range(at: 1), in: content), let price = Int(content[range]) {
                    return price
                }
            }
            return nil
        }else{
            return nil
        }
    }

    private func getPayedNumberFromContent(contentHTML: String?) -> Int? {
        if let content = contentHTML{
            let regex = try? NSRegularExpression(pattern: #"data-haspaid-cnt="(\d+)"#)
            if let match = regex?.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) {
                if let range = Range(match.range(at: 1), in: content), let paidNumber = Int(content[range]) {
                    return paidNumber
                }
            }
            return 0
        }else {
            return nil
        }
    }
    
    // TODO: 修改方法使得其可以读取该回复包含的所有付费内容的ID，返回一个String数组，新的添加到最后面(还需要在struct中增加一个var类型的paymentID数组)
    private func getPaymentId(contentHTML: String?) -> String? {
        if let content = contentHTML {
            let regex = try? NSRegularExpression(pattern: #"data-id="(\d+)"#)
            if let match = regex?.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) {
                if let range = Range(match.range(at: 1), in: content) {
                    return String(content[range])
                }
            }
        }
        return nil
    }
    
    //TODO: 修改方法逻辑，每次调用方法json提交paymentID数组的第一个数据并将其从数组中删除，若数组为空则直接return
    private func payToRead(paymentId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/pay-to-read/payment/pay") else {
            print("invalid Url!")
            completion(false)
            return
        }

        let parameters: [String: Any] = [
            "id": paymentId
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize post data to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
