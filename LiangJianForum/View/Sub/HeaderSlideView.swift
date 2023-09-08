//
//  HeaderSlideView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/25.
//

import SwiftUI

struct HeaderSlideView: View {
    @EnvironmentObject var appsettings: AppSettings
    @State private var slidedata = [SlideData]()
    @State private var transitionTime = "2"
    
    var body: some View {
        VStack {
            if !slidedata.isEmpty {
                SliderView(slides: filterSlidesWithNonEmptyImages(slides: slidedata), transitionTime: $transitionTime)
            } else {
                ShimmerEffectBox().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await fetchHeaderSlide()
        }
    }
    
    private func fetchHeaderSlide() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/header-slideshow/list") else {
            print("Invalid URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("HeaderSlide Exists")

                if let decodedResponse = try? JSONDecoder().decode(HeaderSlideData.self, from: data) {
                    self.transitionTime = decodedResponse.transitionTime
                    self.slidedata = decodedResponse.list
                }
            }
        } catch {
            print("Error fetching Header Slide Data!", error)
        }
    }

    
    func filterSlidesWithNonEmptyImages(slides: [SlideData]) -> [SlideData] {
        var filteredSlides: [SlideData] = []

        for slide in slides {
            if slide.image != ""{
                filteredSlides.append(slide)
            }
        }

        return filteredSlides
    }

}

struct SliderView: View {
    let slides: [SlideData]
    @Binding var transitionTime: String
    @State private var selection = 0

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGray5)

            TabView(selection: $selection) {
                ForEach(0..<slides.count) { i in
                    AsyncImage(url: URL(string: slides[i].image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ShimmerEffectBox()
                    }
                    .ignoresSafeArea()
                    .onTapGesture {
                        if let url = URL(string: slides[i].link) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
            .onReceive(Timer.publish(every: Double(transitionTime) ?? 2, on: .main, in: .common).autoconnect(), perform: { _ in
                withAnimation{
                    selection = selection < slides.count - 1 ? selection + 1 : 0
                }
            })
        }
        .ignoresSafeArea()
    }
}

