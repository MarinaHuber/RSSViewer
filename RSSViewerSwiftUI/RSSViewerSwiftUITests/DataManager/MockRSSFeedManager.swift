//
//  MockRSSFeedManager.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 14.03.2025..
//

import Testing
import Foundation
@testable import RSSViewerSwiftUI


    // Mock implementation of LocalDatabaseRSSProtocol
class MockLocalDatabaseManager: LocalDatabaseRSSProtocol {
    var storedFeeds: [RSSFeed] = []
    var methodCalls = [String]()

    func getFeeds() async -> [RSSFeed] {
        methodCalls.append("getFeeds")
        return storedFeeds
    }

    func saveFeeds(_ feeds: [RSSFeed]) async {
        methodCalls.append("saveFeeds")
        storedFeeds = feeds
    }

    func feedExists(forURL url: String) async -> Bool {
        methodCalls.append("feedExists")
        return storedFeeds.contains(where: { $0.path == url })
    }

    func removeFeed(at offsets: IndexSet) async {
        methodCalls.append("removeFeed(at:)")
        storedFeeds.remove(atOffsets: offsets)
    }

    func removeFeed(withURL url: String) async {
        methodCalls.append("removeFeed(withURL:)")
        storedFeeds.removeAll(where: { $0.path == url })
    }
}

    // Mock implementation of APIManagerRSSProtocol
class MockAPIManager: APIManagerRSSProtocol {
    var methodCalls = [String]()
    var mockData = Data()
    var mockFeed = RSSFeed(path: "https://example.com", content: RSSFeedContent())
    var shouldThrowOnFetch = false
    var shouldThrowOnParse = false

    enum MockError: Error {
        case networkError
        case parsingError
    }

    func fetchData(from url: String) async throws -> Data {
        methodCalls.append("fetchData")
        if shouldThrowOnFetch {
            throw MockError.networkError
        }
        return mockData
    }

    func parseRSS(data: Data, url: String) async throws -> RSSFeed {
        methodCalls.append("parseRSS")
        if shouldThrowOnParse {
            throw MockError.parsingError
        }
        return mockFeed
    }
}
