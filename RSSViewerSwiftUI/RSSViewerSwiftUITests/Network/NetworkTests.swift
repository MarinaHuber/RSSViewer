//
//  NetworkTests.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 09.03.2025..
//

import Testing
import Foundation
@testable import RSSViewerSwiftUI

struct NetworkTests {
    let sut: NetworkService
    let mockSession: MockURLSession

    let someUrl = "https://someurl.com/"
    let invalidUrl = "invalid-url"

    init() {
        mockSession = MockURLSession()
        sut = NetworkService(session: mockSession)
    }

    @Test func getRSSFeedData_Success() async throws {
        let RSSData = """
        <rss>
            <channel>
                <title>Sample Feed</title>
                <description>This is a sample RSS feed</description>
                <link>https://example.com</link>
                <item>
                    <title>Item</title>
                    <description>Item description</description>
                    <link>https://example.com/item</link>
                    <media:thumbnail url="https://example.com/image.jpg" />
                </item>
            </channel>
        </rss>
        """.data(using: .utf8)!

        mockSession.data = RSSData

        let response = try await sut.fetchData(from: someUrl)

        #expect(response == RSSData)
    }

    @Test func getRSSFeedData_RequestFailed() async throws {
        let requestError = URLError(.notConnectedToInternet)
        mockSession.data = Data()
        mockSession.error = requestError

        do {
            let _ = try await sut.fetchData(from: someUrl)
        } catch NetworkServiceError.requestFailed(let error) {
            #expect(error as? URLError == requestError)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func getRSSFeedData_InvalidResponseStatusCode() async throws {
        mockSession.data = Data()
        mockSession.statusCode = 404

        do {
            let _ = try await sut.fetchData(from: someUrl)
            Issue.record("Expected .invalidResponse error, but none was thrown")
        } catch NetworkServiceError.invalidResponse {
            #expect(true)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func getRSSFeedData_InvalidURL() async throws {
        do {
            let _ = try await sut.fetchData(from: invalidUrl)
            Issue.record("Expected .invalidURL error, but none was thrown")
        } catch NetworkServiceError.invalidURL {
            #expect(true)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

