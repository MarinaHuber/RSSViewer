//
//  RSSFeedsView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import SwiftUI

struct RSSFeedsView: View {
    @ObservedObject var viewModel: RSSFeedsViewModel
    @StateObject var router: Router<Route>

    var body: some View {
            List {
                ForEach($viewModel.feeds) { $feed in
                    RSSFeedRowView(feed: feed)
                        .onTapGesture {
                            router.push(.itemView(path: feed.path))
                        }
                }
                .onDelete(perform: { offsets in
                    Task {
                        await viewModel.removeRSSFeed(at: offsets)
                    }
                })
            }
        .navigationTitle("Feed My RSS")
        .accessibilityIdentifier("feedList")

        .refreshable {
            try? await Task.sleep(for: .seconds(0.5))
            await viewModel.syncStoredData()
        }

        .task { await viewModel.syncStoredData() }
        
    }


}


#Preview {
    RSSFeedsView(viewModel: RSSFeedsViewModel(), router: Router<Route>())
       .environmentObject(AppState.shared)
       .environmentObject(Router<Route>())
}
