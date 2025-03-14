//
//  RSSFeedRepository.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 14.03.2025..
//

import Foundation

protocol RSSFeedProtocol {
    func getStoredFeeds() async -> [RSSFeed]
    func saveFeeds(_ feeds: [RSSFeed]) async
    func fetchFeed(from url: String) async throws -> RSSFeed
    func feedExists(for url: String) async -> Bool
    func removeFeed(at offsets: IndexSet) async
}

class RSSFeedManager: RSSFeedProtocol {
    private let localDatabaseManager: LocalDatabaseRSSProtocol
    private let apiManager: APIManagerRSSProtocol

    init(localDatabaseManager: LocalDatabaseRSSProtocol = LocalDatabaseRSSManager(),
         apiManager: APIManagerRSSProtocol = APIManagerRSS()) {
        self.localDatabaseManager = localDatabaseManager
        self.apiManager = apiManager
    }

    func getStoredFeeds() async -> [RSSFeed] {
        return await localDatabaseManager.getFeeds()
    }

    func saveFeeds(_ feeds: [RSSFeed]) async {
        await localDatabaseManager.saveFeeds(feeds)
    }

    func fetchFeed(from url: String) async throws -> RSSFeed {
        let data = try await apiManager.fetchData(from: url)
        return try await apiManager.parseRSS(data: data, url: url)
    }

    func feedExists(for url: String) async -> Bool {
        return await localDatabaseManager.feedExists(forURL: url)
    }

    func removeFeed(at offsets: IndexSet) async {
        await localDatabaseManager.removeFeed(at: offsets)
    }
}
