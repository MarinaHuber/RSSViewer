//
//  RSSFeedsViewModelTests.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 20.02.2025..
//

import Testing
import Foundation
@testable import RSSViewerSwiftUI

struct RSSFeedsViewModelTests {
    let sut: RSSFeedsViewModel!
    let mockService: MockNetworkService

    let someUrl = "https://someurl.com/"
    let invalidUrl = "invalid-url"
    let sampleFeed = RSSFeed(path: "https://someurl.com/", content: RSSFeedContent(title: "Sample Feed", description: "This is a sample RSS feed", linkURL: URL(string: "https://example.com")))

    let RSSData = """
<rss>
    <channel>
        <title>Sample Feed</title>
        <description>This is a sample RSS feed</description>
        <link>https://example.com</link>
    </channel>
</rss>
""".data(using: .utf8)!

    init() {
        mockService = MockNetworkService()
        sut = RSSFeedsViewModel(networkService: mockService)
    }

    @Test func syncStoredData() async throws {
        sut.storedFeeds = [sampleFeed]

        await sut.syncStoredData()

        #expect(sut.feeds == [sampleFeed])
    }


    @Test func addURLSuccessfullyAddsFeed() async throws {
        mockService.mockData = RSSData

        try await sut.addURL(someUrl)

        #expect(sut.feeds.count == 1)
        #expect(sut.feeds.first?.path == someUrl)
    }

    @Test func addURLThrowsErrorWhenFeedAlreadyExists() async throws {
        mockService.mockData = RSSData

        try await sut.addURL(someUrl)

        await #expect(throws: RSSFeedsError.feedExists) {
            try await sut.addURL(someUrl)
        }
    }

    @Test func removeFeedSuccessfullyRemovesItFromFeedList() async throws {
        sut.feeds = [sampleFeed]

        await sut.removeFeed(at: [0])
        #expect(sut.feeds.count == 0)
    }

    @Test func loadRSSFeedSuccessfullyLoadsFeed() async throws {
        mockService.mockData = RSSData

        let feed = try await sut.loadRSSFeed(from: someUrl)

        #expect(feed.path == someUrl)
        #expect(feed.content.title == "Sample Feed")
        #expect(feed.content.description == "This is a sample RSS feed")
    }

}
