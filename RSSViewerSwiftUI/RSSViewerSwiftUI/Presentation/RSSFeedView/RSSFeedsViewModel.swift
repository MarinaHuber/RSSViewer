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

