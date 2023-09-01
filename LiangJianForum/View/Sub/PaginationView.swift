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
    @State private var prevButtonDisabled = false
    @State private var firstPageButtonDisabled = false
    @State private var nextButtonDisabled = false
    let mode: PaginationMode

    var body: some View {
        switch mode {
        case .page:
            if hasPrevPage || hasNextPage {
                ZStack{
                    if isLoading {
                        ProgressView().padding(.bottom, 10)
                    }

                    HStack {
                        Button(action: {
                            if currentPage > 1 && !prevButtonDisabled {
                                currentPage -= 1
                                disableButtons()
                                Task {
                                    await fetchDiscussion()
                                    enableButtons()
                                }
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
                        .disabled(!hasPrevPage || isLoading || prevButtonDisabled)

                        Spacer()

                        Button(action: {
                            if !firstPageButtonDisabled {
                                disableButtons()
                                currentPage = 1
                                Task {
                                    await fetchDiscussion()
                                    enableButtons()
                                }
                            }
                        }) {
                            HStack {
                                Text("First Page")
                                    .foregroundStyle(hasPrevPage ? .blue : .secondary)
                                    .font(.system(size: 14))
                            }
                        }
                        .disabled(!hasPrevPage || isLoading || firstPageButtonDisabled)

                        Spacer()

                        Button(action: {
                            if !nextButtonDisabled {
                                disableButtons()
                                currentPage += 1
                                Task {
                                    await fetchDiscussion()
                                    enableButtons()
                                }
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
                        .disabled(!hasNextPage || isLoading || nextButtonDisabled)
                    }
                }
            }
        case .offset:
            if hasPrevPage || hasNextPage {
                ZStack{
                    if isLoading {
                        ProgressView().padding(.bottom, 10)
                    }

                    HStack {
                        Button(action: {
                            if currentPage > 0 && !prevButtonDisabled {
                                currentPage -= 20
                                disableButtons()
                                Task {
                                    await fetchDiscussion()
                                    enableButtons()
                                }
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
                        .disabled(!hasPrevPage || isLoading || prevButtonDisabled)

                        Spacer()

                        Button(action: {
                            if !firstPageButtonDisabled {
                                disableButtons()
                                currentPage = 0
                                Task {
                                    await fetchDiscussion()
                                    enableButtons()
                                }
                            }
                        }) {
                            HStack {
                                Text("First Page")
                                    .foregroundStyle(hasPrevPage ? .blue : .secondary)
                                    .font(.system(size: 14))
                            }
                        }
                        .disabled(!hasPrevPage || isLoading || firstPageButtonDisabled)

                        Spacer()

                        Button(action: {
                            if !nextButtonDisabled {
                                disableButtons()
                                currentPage += 20
                                Task {
                                    await fetchDiscussion()
                                    enableButtons()
                                }
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
                        .disabled(!hasNextPage || isLoading || nextButtonDisabled)
                    }
                }
            }
        }
        

    }

    private func disableButtons() {
        isLoading = true
        prevButtonDisabled = true
        firstPageButtonDisabled = true
        nextButtonDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            prevButtonDisabled = false
            firstPageButtonDisabled = false
            nextButtonDisabled = false
        }
    }

    private func enableButtons() {
        isLoading = false
        prevButtonDisabled = false
        firstPageButtonDisabled = false
        nextButtonDisabled = false
    }
}

enum PaginationMode {
    case page
    case offset
}
