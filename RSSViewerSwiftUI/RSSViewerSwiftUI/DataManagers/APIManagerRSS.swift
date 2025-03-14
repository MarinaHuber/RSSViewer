//
//  APIManagerRSS.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 14.03.2025..
//

import Foundation

protocol APIManagerRSSProtocol {
    func fetchData(from url: String) async throws -> Data
    func parseRSS(data: Data, url: String) async throws -> RSSFeed
}

class APIManagerRSS: APIManagerRSSProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchData(from url: String) async throws -> Data {
        return try await networkService.fetchData(from: url)
    }

    func parseRSS(data: Data, url: String) async throws -> RSSFeed {
        let parser = RSSParser()
        let content = try await parser.parseRSS(data: data)
        return RSSFeed(path: url, content: content)
    }
}
