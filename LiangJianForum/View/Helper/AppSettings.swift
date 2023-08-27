//
//  AppSettings.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/28.
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @Published var refreshPostView = false
    @Published var refreshReplyView = false
    @Published var refreshProfileView = false
    @Published var isLoggedIn = true
    @Published var FlarumUrl = "https://bbs.cjlu.cc"
    @Published var FlarumName = "量见"
    @Published var token = ""
    @Published var username = ""
    @Published var userId = 0
    
    func refreshPost() {
        refreshPostView.toggle()
    }
    
    func refreshComment() {
        refreshReplyView.toggle()
    }
    func refreshProfile() {
        refreshProfileView.toggle()
    }
}

extension String{
var htmlConvertedString : String{
    let string = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    return string
}}

extension String {
    var htmlConvertedWithoutUrl: String {
        // Remove the specific content
        let contentToRemove = "\n                    if(window.hljsLoader && !document.currentScript.parentNode.hasAttribute('data-s9e-livepreview-onupdate')) {\n                        window.hljsLoader.highlightBlocks(document.currentScript.parentNode);\n                    }\n                "
        var stringWithoutContent = self.replacingOccurrences(of: contentToRemove, with: "")
        
        // Remove JavaScript code
        stringWithoutContent = stringWithoutContent.replacingOccurrences(of: "<script[^>]*?>.*?</script>", with: "", options: .regularExpression, range: nil)
        
        // Remove HTML tags
        let htmlRemovedString = stringWithoutContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // Preserve Markdown code
        let markdownPreservedString = htmlRemovedString.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression, range: nil)
        
        return markdownPreservedString
    }
}





func extractImageURLs(from htmlString: String) -> [String]? {
    var imageURLs: [String] = []
    
    let pattern = "<img[^>]+src\\s*=\\s*\"([^\"]+)\"[^>]*>"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count))
    
    for match in matches {
        let range = match.range(at: 1)
        if let urlRange = Range(range, in: htmlString) {
            let url = String(htmlString[urlRange])
            imageURLs.append(url)
        }
    }
    
    return imageURLs
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, opacity: 1.0)
    }
}



