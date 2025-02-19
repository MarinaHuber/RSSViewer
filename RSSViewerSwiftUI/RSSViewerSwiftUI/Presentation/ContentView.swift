//
//  ContentView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 14.02.2025..
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: RSSFeedsViewModel
    @StateObject var router: Router<Route>
    @State private var inputURL: String = {
#if DEBUG
        let someRSSFeedURLs = ["https://feeds.bbci.co.uk/news/world/rss.xml",
                               "https://feeds.feedburner.com/time/world",
                               "https://www.cnbc.com/id/100727362/device/rss/rss.html"]
        return someRSSFeedURLs.randomElement() ?? ""
#else
        return ""
#endif
    }()

    var body: some View {
        NavigationStack(path: $router.currentRoute) {
            ZStack {
                GlobeView()
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                ZStack(alignment: .leading) {
                    SearchView(rssURL: $inputURL)

                }

                Button("Add a Feed") {
                    addNewFeed()
                    router.push(.openFeed)

                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 54)
                .foregroundColor(.gray)
                .background(.white)
                .cornerRadius(100)
                .padding(.top, 150)
            }
            .navigationDestination(for: Route.self)  { route in
                switch route {
                case let .itemView(path, viewModel):
                    RSSFeedDetailView(path: path, viewModel: viewModel)
                case .openFeed:
                    RSSFeedsView(viewModel: viewModel, router: router)

                }
            }

        }

    }


    private func addNewFeed() {
        Task {
            do {
                try await viewModel.addURL(inputURL)
            } catch {
              //  show(error: error)
            }
        }
    }
}



#Preview {
    ContentView(viewModel: RSSFeedsViewModel(), router: Router())
}

