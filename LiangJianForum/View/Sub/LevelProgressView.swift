//
//  LevelProgressView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/11.
//

import SwiftUI
import Charts
import Shimmer

struct LevelProgressView: View {
    let isUserVip : Bool
    let currentExp : Int
    
    var body: some View {
//        VStack{
//            VStack{
//                ProgressView(value: getUserLevelUpPercent(Exp: currentExp)) {
//                    Text("Lv. \(getUserLevel(Exp: currentExp))")
//                } currentValueLabel: {
//                    Text("升级所需经验 \(currentExp) / \((getUserLevel(Exp: currentExp) + 1) * 135)")
//                }
//            }
//            .progressViewStyle(.linear)
//            .tint(.purple)
//        }
        
        GroupBox(label: LevelChartLabel(Exp: currentExp, isVIP: isUserVip)
        ){
            Chart {
                BarMark(
                    x: .value("current Exp", currentExp),
                    y: .value("user", " ")
                )
                .alignsMarkStylesWithPlotArea()
                .foregroundStyle(isUserVip ? .linearGradient(
                    colors: [Color(hex: "fcb0f3"), Color(hex: "3d05dd")],
                    startPoint: .leading,
                    endPoint: .trailing
                ) : .linearGradient(
                    colors: [.blue, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            }
//            .chartPlotStyle { plotContent in
//              plotContent
//                .background(.green.opacity(0.2))
//                
//            }
            .animation(.easeInOut(duration: 2), value: currentExp)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .chartXScale(domain: 0...((getUserLevel(Exp: currentExp) + 1) * 135))
            .frame(height: 45)
            .chartYAxisLabel(position: .bottom) {
                Text("升级所需经验 \(currentExp) / \((getUserLevel(Exp: currentExp) + 1) * 135)")
            }
        }
        .ignoresSafeArea()
    }
    
    private func getUserLevel(Exp : Int) -> Int{
        return Int(currentExp / 135)
    }
    
    private func getUserLevelUpPercent(Exp: Int) -> Double {
        let currentLevelExp = getUserLevel(Exp: Exp) * 135
        let nextLevelExp = (getUserLevel(Exp: Exp) + 1) * 135
        
        let expInCurrentLevel = Exp - currentLevelExp
        let expNeededForNextLevel = nextLevelExp - currentLevelExp
        
        return Double(expInCurrentLevel) / Double(expNeededForNextLevel)
    }
}

struct LevelChartLabel: View{
    let Exp : Int
    let isVIP : Bool
    
    var body: some View {
        if !isVIP{
            Text(getUserLevel(Exp: Exp))
                .animation(.default, value: Exp)
        }else{
            Text(getUserLevel(Exp: Exp))
                .animation(.default, value: Exp)
                .shimmering(bandSize: 0.5)
                .multilineTextAlignment(.center)
                .tracking(0.5)
                .bold()
                .overlay {
                    LinearGradient(
                        colors: [Color(hex: "f9c58d"), Color(hex: "f492f0")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text(getUserLevel(Exp: Exp))
                            .shimmering(bandSize: 0.5)
                            .multilineTextAlignment(.center)
                            .tracking(0.5)
                            .bold()
                    )
                }
        }

    }
    
    private func getUserLevel(Exp: Int) -> String {
        let level = Exp / 135
        return String(format: "Lv.%3d", level)
    }

}

//#Preview {
//    LevelProgressView(isUserVip: true, currentExp: 500)
//}
