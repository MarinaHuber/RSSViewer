//
//  RSSFeedDetailsView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 18.02.2025..
//

import SwiftUI
import Combine

struct RSSFeedDetailView: View {
    let path: String
    @ObservedObject var viewModel: RSSFeedsViewModel

    @State private var webViewModel: WebViewModel?
    @State private var isLoading = false
    @State private var feed: RSSFeed?

    private var items: [RSSItem] { feed?.content.items ?? [] }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(items) { item in
                    RSSFeedItemRow(item: item)
                        .onTapGesture {
                            openLink(item.linkURL)
                        }
                    Divider()
                }
            }
        }
        .navigationTitle(feed?.content.title ?? "")
        .navigationBarTitleDisplayMode(.inline)

        .task { await loadFeed() }

        .sheet(item: $webViewModel) { model in
        //show web view
            ZStack {
                WebView(isLoading: $isLoading, url: model.linkURL)

                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
            }        }
    }

    private func openLink(_ linkURL: URL?) {
        webViewModel = WebViewModel(linkURL: linkURL)
    }

    private func loadFeed() async {
        do {
            feed = try await viewModel.loadRSSFeed(from: path)
        } catch {
        //show error

        }
    }
}

#Preview {
    RSSFeedDetailView(path: "", viewModel: RSSFeedsViewModel(networkService: NetworkService()))
}

struct WebViewModel: Identifiable {
    var id = UUID()
    var linkURL: URL?
}

