//
//  LoadMoreButton.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/24.
//

import SwiftUI

struct LoadMoreButton: View {
    @Binding var selectedSortOption: String
    @Binding var currentPage: Int
    @Binding var isLoading: Bool
    var commentCount: Int
    var postID: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Button(action: {
                // Move the logic from the original code here
            }) {
                HStack {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.blue)
                        .font(.system(size: 17))
                        .padding(.top, 1)
                    Text("Load More")
                        .foregroundStyle(.blue)
                        .font(.system(size: 14))
                }
            }
            .disabled(loadMoreButtonDisabled())
        }
        .frame(width: (loadMoreButtonDisabled()) ? 0 : 100, height: (loadMoreButtonDisabled()) ? 0 : 23)
        .background((colorScheme == .dark ? Color(hex: "0D1117") : Color(hex: "f0f0f5")))
        .cornerRadius(10)
        .opacity((loadMoreButtonDisabled()) ? 0 : 0.9)
        .padding(.bottom)
        .onChange(of: selectedSortOption) { newValue in
            // Move the logic from the original code here
        }
    }

    private func loadMoreButtonDisabled() -> Bool {
        // Move the logic from the original code here
    }
}
