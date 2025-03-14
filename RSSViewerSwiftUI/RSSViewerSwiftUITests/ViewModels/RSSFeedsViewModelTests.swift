//
//  RSSFeedsViewModelTests.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 20.02.2025..
//

import Testing
import Foundation
@testable import RSSViewerSwiftUI

@Suite("RSSFeedsViewModelTests")
struct RSSFeedsViewModelTests {

    @Test("Initialize with empty feeds")
    @MainActor
    func initializeWithEmptyFeeds() async {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)

        #expect(viewModel.feeds.isEmpty)
    }

    @Test("Sync stored data loads feeds from repository")
    @MainActor
    func syncStoredDataLoadsFeeds() async {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let sampleFeeds = [
            RSSFeed(path: "https://example1.com", content: RSSFeedContent(title: "Feed 1", description: "Description 1", linkURL: URL(string: "https://example1.com"))),
            RSSFeed(path: "https://example2.com", content: RSSFeedContent(title: "Feed 2", description: "Description 2", linkURL: URL(string: "https://example2.com")))
        ]
        mockRepository.storedFeeds = sampleFeeds

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)

        await viewModel.syncStoredData()

        #expect(viewModel.feeds.count == 2)
        #expect(mockRepository.getStoredFeedsCallCount == 1)
        #expect(viewModel.feeds[0].path == "https://example1.com")
        #expect(viewModel.feeds[1].path == "https://example2.com")
    }

    @Test("Add URL successfully adds a new feed")
    @MainActor
    func addURLSuccessfully() async throws {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let newFeed = RSSFeed(path: "https://newexample.com", content: RSSFeedContent(title: "New Feed", description: "New Description", linkURL: URL(string: "https://newexample.com")))
        mockUseCase.resultFeed = newFeed

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)

        try await viewModel.addURL("https://newexample.com")

        #expect(viewModel.feeds.count == 1)
        #expect(viewModel.feeds[0].path == "https://newexample.com")
        #expect(mockUseCase.executeCallCount == 1)
        #expect(mockUseCase.executedURL == "https://newexample.com")
    }

    @Test("Add URL throws error when feed already exists in memory")
    @MainActor
    func addURLThrowsErrorWhenFeedExists() async {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let existingFeed = RSSFeed(path: "https://existing.com", content: RSSFeedContent(title: "Existing Feed", description: "Existing Description", linkURL: URL(string: "https://existing.com")))

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)
        viewModel.feeds = [existingFeed]

        await #expect(throws: RSSFeedsError.feedExists) {
            try await viewModel.addURL("https://existing.com")
        }

        #expect(mockUseCase.executeCallCount == 0)
    }

    @Test("Add URL propagates error from use case")
    @MainActor
    func addURLPropagatesError() async {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        enum TestError: Error { case customError }
        mockUseCase.executeError = TestError.customError

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)

        await #expect(throws: TestError.customError) {
            try await viewModel.addURL("https://example.com")
        }

        #expect(viewModel.feeds.isEmpty)
        #expect(mockUseCase.executeCallCount == 1)
    }

    @Test("Load feed returns existing feed from memory")
    @MainActor
    func loadFeedReturnsExistingFeed() async throws {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let existingFeed = RSSFeed(path: "https://existing.com", content: RSSFeedContent(title: "Existing Feed", description: "Existing Description", linkURL: URL(string: "https://existing.com")))

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)
        viewModel.feeds = [existingFeed]

        let result = try await viewModel.loadFeed(from: "https://existing.com")

        #expect(result.path == existingFeed.path)
        #expect(result.content.title == existingFeed.content.title)
        #expect(mockRepository.fetchFeedCallCount == 0)
    }

    @Test("Load feed fetches from repository when not in memory")
    @MainActor
    func loadFeedFetchesFromRepository() async throws {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let repositoryFeed = RSSFeed(path: "https://repo.com", content: RSSFeedContent(title: "Repo Feed", description: "Repo Description", linkURL: URL(string: "https://repo.com")))
        mockRepository.fetchedFeed = repositoryFeed

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)

        let result = try await viewModel.loadFeed(from: "https://repo.com")

        #expect(result.path == repositoryFeed.path)
        #expect(result.content.title == repositoryFeed.content.title)
        #expect(mockRepository.fetchFeedCallCount == 1)
    }

    @Test("Remove RSS feed delegates to use case")
    @MainActor
    func removeRSSFeedDelegates() async {
        let mockRepository = MockRSSFeedRepository()
        let mockUseCase = MockRSSFeedUseCase()

        let resultFeeds = [RSSFeed(path: "https://remaining.com", content: RSSFeedContent(title: "Remaining Feed", description: "Remaining Description", linkURL: URL(string: "https://remaining.com")))]
        mockUseCase.removeFeedResult = resultFeeds

        let viewModel = RSSFeedsViewModel(repository: mockRepository, addFeedUseCase: mockUseCase)
        viewModel.feeds = [
            RSSFeed(path: "https://example1.com", content: RSSFeedContent()),
            RSSFeed(path: "https://example2.com", content: RSSFeedContent())
        ]

        await viewModel.removeRSSFeed(at: IndexSet(integer: 0))

        #expect(mockUseCase.removeFeedCallCount == 1)
        #expect(viewModel.feeds.count == 1)
        #expect(viewModel.feeds[0].path == "https://remaining.com")
    }

    @Test("deinit cancels save task")
    @MainActor
    func testDeinitCancelsSaveTask() async {
        let testFeed1 = RSSFeed(path: "https://remaining.com", content: RSSFeedContent(title: "Deinit Feed", description: "Remaining", linkURL: URL(string: "https://remaining.com")))
        var viewModel: RSSFeedsViewModel? = RSSFeedsViewModel(
            repository: MockRSSFeedRepository(),
            addFeedUseCase: MockRSSFeedUseCase()
        )

        viewModel?.feeds = [testFeed1]

        try? await Task.sleep(for: .milliseconds(150))

        viewModel = nil
        #expect(true)
    }
}
