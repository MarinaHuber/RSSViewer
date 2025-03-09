//
//  MockNetwork.swift
//  RSSViewerSwiftUITests
//
//  Created by Marina Huber on 09.03.2025..
//

import Foundation
@testable import RSSViewerSwiftUI

class MockURLSession: NetworkService.URLSessionProtocol {
    var data: Data?
    var error: Error?
    var statusCode: Int = 200

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data ?? Data(), response)
    }
}
