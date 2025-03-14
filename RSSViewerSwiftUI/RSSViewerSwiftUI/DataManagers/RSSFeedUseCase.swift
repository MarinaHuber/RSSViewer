//
//  RSSFeedUseCase.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 14.03.2025..
//

import Foundation

protocol RSSFeedUseCaseProtocol {
    func execute(url: String) async throws -> RSSFeed
    func removeFeed(feeds: [RSSFeed], at offsets: IndexSet) async -> [RSSFeed]
}

class RSSFeedUseCase: RSSFeedUseCaseProtocol {
    private let repository: RSSFeedProtocol

    init(repository: RSSFeedProtocol = RSSFeedManager()) {
        self.repository = repository
    }

    func execute(url: String) async throws -> RSSFeed {
        guard !(await repository.feedExists(for: url)) else {
            throw RSSFeedsError.feedExists
        }

        return try await repository.fetchFeed(from: url)
    }

    func removeFeed(feeds: [RSSFeed], at offsets: IndexSet) async -> [RSSFeed] {
        await repository.removeFeed(at: offsets)

        var updatedFeeds = feeds
        updatedFeeds.remove(atOffsets: offsets)
        return updatedFeeds
    }
}

enum RSSFeedsError: LocalizedError {
    case feedExists

    var errorDescription: String? {
        switch self {
        case .feedExists:
            return "RSS feed already in list"
        }
    }
}
