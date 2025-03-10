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
                    if inputURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorAlert.show(error: NSError(
                            domain: "InputValidation",
                            code: 100,
                            userInfo: [NSLocalizedDescriptionKey: "Please enter a valid RSS URL"]
                        ))
                    } else {
                        addNewFeed()
                        router.push(.openFeed)
                    }
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
            .errorAlert(errorAlert)
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
                               "https://rss.dw.com/xml/rss_en_science",
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
                RSSLogger.shared.log(.error, message: "Failed to add feed: \(inputURL). Error: \(error.localizedDescription)")
                errorAlert.show(error: error)
            }
        }
    }
}



#Preview {
    ContentView(viewModel: RSSFeedsViewModel(), router: Router())
}

