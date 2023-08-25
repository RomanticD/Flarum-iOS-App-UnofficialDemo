//
//  PaginationView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/24.
//

import SwiftUI

struct PaginationView: View {
    let hasPrevPage: Bool
    let hasNextPage: Bool
    @Binding var currentPage: Int
    @Binding var isLoading: Bool
    let fetchDiscussion: () async -> Void

    var body: some View {
        if hasPrevPage || hasNextPage {
            HStack {
                Button(action: {
                    if currentPage > 1 {
                        currentPage -= 1
                    }
                    isLoading = true
                    Task {
                        await fetchDiscussion()
                        isLoading = false
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(hasPrevPage ? .blue : .secondary)
                            .font(.system(size: 20))
                            .padding(.top, 1)
                        Text("Prev")
                            .foregroundStyle(hasPrevPage ? .blue : .secondary)
                            .font(.system(size: 14))
                    }
                }
                .padding(.leading)
                .disabled(!hasPrevPage)

                Spacer()

                Button(action: {
                    isLoading = true
                    currentPage = 1
                    isLoading = false
                    Task {
                        await fetchDiscussion()
                        isLoading = false
                    }
                }) {
                    HStack {
                        Text("First Page")
                            .foregroundStyle(hasPrevPage ? .blue : .secondary)
                            .font(.system(size: 14))
                    }
                }
                .disabled(!hasPrevPage)

                Spacer()

                Button(action: {
                    currentPage += 1
                    isLoading = true
                    Task {
                        await fetchDiscussion()
                        isLoading = false
                    }
                }) {
                    HStack {
                        Text("Next")
                            .foregroundStyle(hasNextPage ? .blue : .secondary)
                            .font(.system(size: 14))
                        Image(systemName: "chevron.right")
                            .foregroundColor(hasNextPage ? .blue : .secondary)
                            .font(.system(size: 20))
                            .padding(.top, 1)
                    }
                }
                .padding(.trailing)
                .disabled(!hasNextPage)
            }
        }
    }
}
