//
//  MoneyConditionRecordContentLoader.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/7.
//

import SwiftUI

struct MoneyConditionRecordContentLoader: View {
    var body: some View {
        List{
            Section("当前资产"){
                HStack{
                    ShimmerEffectBox()
                        .frame(height: 60)
                        .cornerRadius(5)
                }
            }
            
            Section("资产记录"){
                ForEach(0..<10, id: \.self) { item in
                    HStack{
                        VStack(alignment: .leading){
                            ShimmerEffectBox()
                                .frame(height: 20)
                            
                            ShimmerEffectBox()
                                .frame(height: 20)
                                .padding(.top)
                        }
                        ShimmerEffectBox()
                            .font(.title)
                            .frame(width: 80, height: 50)
                            .padding(.leading, 30)
                            .padding(.trailing, 10)
                        
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
