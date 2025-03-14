//
//  RSSViewerSwiftUITests.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 14.02.2025..
//

import Testing
import Foundation
@testable import RSSViewerSwiftUI


class MockNetworkService: NetworkServiceProtocol {
    var mockData: Data?

    func fetchData(from url: String) async throws -> Data {
        if let data = mockData {
            return data
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

// -------------
// MOCK MockRSSFeedRepository
// -------------

final class MockRSSFeedRepository: RSSFeedProtocol {
    var storedFeeds: [RSSFeed] = []
    var fetchedFeed: RSSFeed?
    var error: Error?
    var saveCallCount = 0
    var getStoredFeedsCallCount = 0
    var fetchFeedCallCount = 0
    var feedExistsCallCount = 0
    var removeFeedCallCount = 0

    func saveFeeds(_ feeds: [RSSFeed]) async {
        saveCallCount += 1
        storedFeeds = feeds
    }

    func getStoredFeeds() async -> [RSSFeed] {
        getStoredFeedsCallCount += 1
        return storedFeeds
    }

    func fetchFeed(from url: String) async throws -> RSSFeed {
        fetchFeedCallCount += 1
        if let error = error {
            throw error
        }
        return fetchedFeed ?? RSSFeed(path: url, content: RSSFeedContent(title: "Mock Feed", description: "Mock Description", linkURL: URL(string: "https://example.com")))
    }

    func feedExists(for url: String) async -> Bool {
        feedExistsCallCount += 1
        return storedFeeds.contains(where: { $0.path == url })
    }

    func removeFeed(at offsets: IndexSet) async {
        removeFeedCallCount += 1
        storedFeeds.remove(atOffsets: offsets)
    }
}

// -------------
// MOCK MockRSSFeedUseCase
// -------------

final class MockRSSFeedUseCase: RSSFeedUseCaseProtocol {
    var executedURL: String?
    var resultFeed: RSSFeed?
    var executeError: Error?
    var removeFeedResult: [RSSFeed] = []
    var executeCallCount = 0
    var removeFeedCallCount = 0

    func execute(url: String) async throws -> RSSFeed {
        executeCallCount += 1
        executedURL = url

        if let error = executeError {
            throw error
        }

        return resultFeed ?? RSSFeed(path: url, content: RSSFeedContent(title: "Mock Feed", description: "Mock Description", linkURL: URL(string: "https://example.com")))
    }

    func removeFeed(feeds: [RSSFeed], at offsets: IndexSet) async -> [RSSFeed] {
        removeFeedCallCount += 1
        return removeFeedResult
    }
}

