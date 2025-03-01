//
//  RSSFeedsViewModel.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import Foundation
import Combine

class RSSFeedsViewModel: ObservableObject {
    @Published var feeds = [RSSFeed]()
    private let networkService: NetworkServiceProtocol
 //   private var feedSubscription: AnyCancellable?

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func checkForNewItems() async {
        for index in feeds.indices {
            guard let newFeed = try? await loadRSSFeed(from: feeds[index].path, fromBackground: true) else { continue }

            let newFeedItemsSet = Set<RSSItem>(newFeed.content.items)
            let oldFeedItemsSet = Set<RSSItem>(feeds[index].content.items)
            let newItems = newFeedItemsSet.subtracting(oldFeedItemsSet)
            if newItems.count > 0 {
                await updateFeedItems(forIndex: index, with: newFeed.content.items, newItemCount: newItems.count)
            }
        }
    }

    func addURL(_ urlString: String) async throws {
        guard !feedExists(for: urlString) else { throw RSSFeedsError.feedExists }

        let feed = try await loadRSSFeed(from: urlString)
        await addFeed(feed)
    }

    func loadRSSFeed(from urlString: String, fromBackground: Bool = false) async throws -> RSSFeed {
        let parser = RSSParser()
        let data = try await networkService.fetchData(from: urlString)
        let content = try await parser.parseRSS(data: data)
        return RSSFeed(path: urlString, content: content)
    }

    @MainActor
    private func updateFeedItems(forIndex index: Int, with items: [RSSItem], newItemCount count: Int) {
        feeds[index].newItemCount = count
        feeds[index].content.items = items
    }

    private func feedExists(for urlString: String) -> Bool {
        feeds.contains(where: { $0.path == urlString })
    }
    
    @MainActor
    private func addFeed(_ feed: RSSFeed) {
        feeds.append(feed)
    }

    @MainActor
    func removeFeed(at offsets: IndexSet) {
        feeds.remove(atOffsets: offsets)
    }

}

// Required for RSSFeed Models
extension RSSFeedsViewModel: Equatable {
    public static func == (lhs: RSSFeedsViewModel, rhs: RSSFeedsViewModel) -> Bool {
        return lhs.feeds == rhs.feeds
    }
}

extension RSSFeedsViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(feeds)
    }
}

