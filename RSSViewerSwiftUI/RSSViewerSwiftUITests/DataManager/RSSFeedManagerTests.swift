//
//  RSSFeedManagerTests.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 14.03.2025..
//

import Testing
import Foundation
@testable import RSSViewerSwiftUI


@Suite("RSSFeedManager Tests")
struct RSSFeedManagerTests {

    @Test("Get stored feeds delegates correctly")
    func getStoredFeedsDelegatesCorrectly() async throws {
            // Arrange
        let mockLocalDb = MockLocalDatabaseManager()
        let mockApi = MockAPIManager()
        let sut = RSSFeedManager(localDatabaseManager: mockLocalDb, apiManager: mockApi)

        let expectedFeeds = [
            RSSFeed(path: "https://example.com", content: RSSFeedContent()) // replace -> RSSFeed(path: "https://someurl.com/", content: RSSFeedContent(title: "Sample Feed", description: "This is a sample RSS feed", linkURL: URL(string: "https://example.com")))
        ]
        mockLocalDb.storedFeeds = expectedFeeds

            // Act
        let result = await sut.getStoredFeeds()

            // Assert
        #expect(result.count == expectedFeeds.count)
        #expect(result[0].content.title == expectedFeeds[0].content.title)
        #expect(mockLocalDb.methodCalls.contains("getFeeds"))
    }

    @Test("Save feeds delegates correctly")
    func saveFeedsDelegatesCorrectly() async throws {
            // Arrange
        let mockLocalDb = MockLocalDatabaseManager()
        let mockApi = MockAPIManager()
        let sut = RSSFeedManager(localDatabaseManager: mockLocalDb, apiManager: mockApi)

        let feedsToSave = [
            RSSFeed(path: "https://example.com", content: RSSFeedContent())
        ]

            // Act
        await sut.saveFeeds(feedsToSave)

            // Assert
        #expect(mockLocalDb.storedFeeds.count == feedsToSave.count)
        #expect(mockLocalDb.storedFeeds[0].content.title == feedsToSave[0].content.title)
        #expect(mockLocalDb.methodCalls.contains("saveFeeds"))
    }

    @Test("Fetch feed succeeds")
    func fetchFeedSuccess() async throws {
            // Arrange
        let mockLocalDb = MockLocalDatabaseManager()
        let mockApi = MockAPIManager()
        let sut = RSSFeedManager(localDatabaseManager: mockLocalDb, apiManager: mockApi)

        let testURL = "https://example.com/feed"
        let expectedFeed = RSSFeed(path: "https://example.com", content: RSSFeedContent())
        mockApi.mockFeed = expectedFeed

            // Act
        let result = try await sut.fetchFeed(from: testURL)

            // Assert
        #expect(result.path == expectedFeed.path)
        #expect(mockApi.methodCalls.contains("fetchData"))
        #expect(mockApi.methodCalls.contains("parseRSS"))
    }

    @Test("Fetch feed fails with network error")
    func fetchFeedNetworkFailure() async throws {
            // Arrange
        let mockLocalDb = MockLocalDatabaseManager()
        let mockApi = MockAPIManager()
        let sut = RSSFeedManager(localDatabaseManager: mockLocalDb, apiManager: mockApi)

        mockApi.shouldThrowOnFetch = true

            // Act & Assert
        await #expect(throws: MockAPIManager.MockError.networkError) {
            try await sut.fetchFeed(from: "https://example.com")
        }

        #expect(mockApi.methodCalls.contains("fetchData"))
        #expect(!mockApi.methodCalls.contains("parseRSS"))
    }

    @Test("Feed exists check works correctly")
    func feedExistsCheck() async throws {
            // Arrange
        let mockLocalDb = MockLocalDatabaseManager()
        let mockApi = MockAPIManager()
        let sut = RSSFeedManager(localDatabaseManager: mockLocalDb, apiManager: mockApi)

        let existingURL = "https://example.com"
        let nonExistingURL = "https://nonexisting.com"
        mockLocalDb.storedFeeds = [RSSFeed(path: "https://example.com", content: RSSFeedContent())]

            // Act & Assert
        let exists = await sut.feedExists(for: existingURL)
        let notExists = await sut.feedExists(for: nonExistingURL)

        #expect(exists)
        #expect(!notExists)
        #expect(mockLocalDb.methodCalls.contains("feedExists"))
    }

    @Test("Remove feed works correctly")
    func removeFeed() async throws {
            // Arrange
        let mockLocalDb = MockLocalDatabaseManager()
        let mockApi = MockAPIManager()
        let sut = RSSFeedManager(localDatabaseManager: mockLocalDb, apiManager: mockApi)

        mockLocalDb.storedFeeds = [
            RSSFeed(path: "https://example.com", content: RSSFeedContent()),
            RSSFeed(path: "https://nonexisting.com", content: RSSFeedContent())
        ]

            // Act
        await sut.removeFeed(at: IndexSet(integer: 0))

            // Assert
        #expect(mockLocalDb.storedFeeds.count == 1)
        #expect(mockLocalDb.methodCalls.contains("removeFeed(at:)"))
    }
}

@main
struct RSSFeedManagerTestSuite {
    static func main() async {
            //    await TestRunner().run()
    }
}
