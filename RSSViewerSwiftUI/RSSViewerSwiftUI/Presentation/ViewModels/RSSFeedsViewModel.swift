//
//  RSSFeedsViewModel.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import Foundation

@MainActor
class RSSFeedsViewModel: ObservableObject {
    @Published var feeds = [RSSFeed]()

    private let repository: RSSFeedProtocol
    private let addFeedUseCase: RSSFeedUseCaseProtocol
    private var saveTask: Task<Void, Never>? = nil

    init(repository: RSSFeedProtocol = RSSFeedManager(),
         addFeedUseCase: RSSFeedUseCaseProtocol = RSSFeedUseCase()) {
        self.repository = repository
        self.addFeedUseCase = addFeedUseCase

        setupFeedsObserver()
    }

    deinit {
        saveTask?.cancel()
    }

    func addURL(_ urlString: String) async throws {
            // Check in-memory feeds first (for efficiency)
        if feeds.contains(where: { $0.path == urlString }) {
            throw RSSFeedsError.feedExists
        }
            // Check local db feeds
        let feed = try await addFeedUseCase.execute(url: urlString)
        feeds.append(feed)
    }

    func syncStoredData() async {
        let storedFeeds = await repository.getStoredFeeds()
        feeds = storedFeeds
    }


    func loadFeed(from path: String) async throws -> RSSFeed {
        if let existingFeed = feeds.first(where: { $0.path == path }) {
            return existingFeed
        }

            // Otherwise fetch from repository
        return try await repository.fetchFeed(from: path)
    }

    func removeRSSFeed(at offsets: IndexSet) async {
        feeds = await addFeedUseCase.removeFeed(feeds: feeds, at: offsets)
    }

    private func setupFeedsObserver() {
            // Using property wrapper observation in Swift 5.7+
        Task {
            var lastFeedsValue = self.feeds

            while !Task.isCancelled {
                    // Wait for change using async property access
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms check interval

                if lastFeedsValue != self.feeds {
                        // Feeds changed, save them
                    let feedsToSave = self.feeds
                    lastFeedsValue = feedsToSave

                        // Cancel previous save task if it exists
                    saveTask?.cancel()

                        // Create new save task
                    saveTask = Task.detached { [weak self] in
                        guard let self = self else { return }
                        await self.repository.saveFeeds(feedsToSave)
                    }
                }
            }
        }
    }
}
