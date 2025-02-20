//
//  RSSFeedsView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import SwiftUI

struct RSSFeedsView: View {
    @StateObject var viewModel: RSSFeedsViewModel
    @StateObject var router: Router<Route>
    @EnvironmentObject var appState: AppState

    var body: some View {
            List {
                ForEach($viewModel.feeds) { $feed in
                    RSSFeedRowView(feed: $feed)
                        .onTapGesture {
                            router.push(.itemView(path: feed.path, viewModel: viewModel))
                        }
                }
                .onDelete(perform: removeRSSFeed)

            }
        .navigationTitle("Feed My RSS")
        .accessibilityIdentifier("feedList")
        .onChange(of: appState.checkForNewItems) { _, newValue in
            defer { appState.checkForNewItems = false }
            guard newValue else { return }

            Task { await viewModel.checkForNewItems() }
        }
    }

    func removeRSSFeed(at offsets: IndexSet) {
        viewModel.removeFeed(at: offsets)
    }

}


#Preview {
    RSSFeedsView(viewModel: RSSFeedsViewModel(), router: Router<Route>())
       .environmentObject(AppState.shared)
       .environmentObject(Router<Route>())
}
