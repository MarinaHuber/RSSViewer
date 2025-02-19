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

    var body: some View {
            List {
                ForEach($viewModel.feeds) { $feed in
                    RSSFeedRowView(feed: $feed)
                        .onTapGesture {
                            router.push(.itemView(path: feed.path, viewModel: viewModel))
                        }
                }
            }
        .navigationTitle("Feed My RSS")
        .accessibilityIdentifier("feedList")
    }

}


#Preview {
    RSSFeedsView(viewModel: RSSFeedsViewModel(), router: Router<Route>())
       .environmentObject(AppState.shared)
       .environmentObject(Router<Route>())
}
