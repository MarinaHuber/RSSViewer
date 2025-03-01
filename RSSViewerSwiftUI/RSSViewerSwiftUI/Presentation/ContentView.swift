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
    @State private var inputURL: String = ""
    @EnvironmentObject var errorAlert: ErrorAlert

    var body: some View {
        NavigationStack(path: $router.currentRoute) {
            ZStack {
                GlobeView()
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                ZStack(alignment: .leading) {
                    SearchView(rssURL: $inputURL)

                }

                Button("Add New Feed") {
                    addNewFeed()
                    router.push(.openFeed)
                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 54)
                .foregroundColor(.gray)
                .background(.white)
                .cornerRadius(100)
                .padding(.top, 150)
            }
            .onAppear() {
                updateInputURL()
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

    private func updateInputURL() {
#if DEBUG
        let someRSSFeedURLs = ["https://feeds.bbci.co.uk/news/world/rss.xml",
                               "https://abcnews.go.com/abcnews/internationalheadlines",
                               "https://www.cbsnews.com/latest/rss/world",
                               "https://feeds.feedburner.com/time/world"]
        inputURL = someRSSFeedURLs.randomElement() ?? ""
#else
        inputURL = ""
#endif
    }


    private func addNewFeed() {
        Task {
            do {
                try await viewModel.addURL(inputURL)
            } catch {
                errorAlert.show(error: error)
            }
        }
    }
}



#Preview {
    ContentView(viewModel: RSSFeedsViewModel(), router: Router())
}

