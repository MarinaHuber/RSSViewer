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
