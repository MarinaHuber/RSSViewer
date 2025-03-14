//
//  LocalDatabaseRSSManager.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 14.03.2025..
//

import Foundation

protocol LocalDatabaseRSSProtocol {
    func getFeeds() async -> [RSSFeed]
    func saveFeeds(_ feeds: [RSSFeed]) async
    func feedExists(forURL url: String) async -> Bool
    func removeFeed(at offset: IndexSet) async
}

class LocalDatabaseRSSManager: LocalDatabaseRSSProtocol {
    @UserDefaultsWrapper(key: "storedFeeds", defaultValue: [])
    private var storedFeeds: [RSSFeed]

    private let logger: LoggerProtocol

    init(logger: LoggerProtocol = DefaultLoggerImplementation()) {
        self.logger = logger
    }

    func getFeeds() async -> [RSSFeed] {
        return storedFeeds
    }

    func saveFeeds(_ feeds: [RSSFeed]) async {
        storedFeeds = feeds
    }

    func feedExists(forURL url: String) async -> Bool {
        return storedFeeds.contains(where: { $0.path == url })
    }

    func removeFeed(at offsets: IndexSet) async {
        storedFeeds.remove(atOffsets: offsets)
        logger.log(level: .info,
                   message: "Successfully removed \(1) feed. Remaining feeds: \(storedFeeds.count)",
                   file: #file,
                   function: #function,
                   line: #line)
    }
}
