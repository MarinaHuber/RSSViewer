//
//  NetworkServiceProtocol.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchData(from urlString: String) async throws -> Data
   // func fetchDataFromBackground(from urlString: String) async throws -> Data
}

class NetworkService: NSObject, NetworkServiceProtocol {
    internal protocol URLSessionProtocol {
        func data(from url: URL) async throws -> (Data, URLResponse)
    }

    typealias CompletionCallback = (Result<Data, NetworkServiceError>) -> Void

    private let session: URLSessionProtocol
    private var backgroundSession: URLSession?

    private var onComplete: CompletionCallback?

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchData(from urlString: String) async throws(NetworkServiceError) -> Data {
        guard urlString.isValidURL, let url = URL(string: urlString) else {
            throw .invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw .requestFailed(error)
        }

        try validateResponse(response)

        return data
    }

//    func fetchDataFromBackground(from urlString: String, onComplete: @escaping CompletionCallback) {
//        self.onComplete = onComplete
//
//        guard urlString.isValidURL, let url = URL(string: urlString) else {
//            onComplete(.failure(.invalidURL))
//            return
//        }
//
//        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "vukusic.marko.networkservice.background")
//        backgroundSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: nil)
//
//        let task = backgroundSession!.downloadTask(with: url)
//        task.resume()
//    }
//
//    func fetchDataFromBackground(from urlString: String) async throws -> Data {
//        try await withCheckedThrowingContinuation { continuation in
//            fetchDataFromBackground(from: urlString) { result in
//                continuation.resume(with: result)
//            }
//        }
//    }

    private func validateResponse(_ response: URLResponse) throws(NetworkServiceError) {
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw .invalidResponse
        }
    }
}

extension NetworkService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            onComplete?(.success(data))
        } catch {
            onComplete?(.failure(.invalidResponse))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }

        onComplete?(.failure(.requestFailed(error)))
    }
}
//MARK:- Move to files
extension URLSession: NetworkService.URLSessionProtocol {}

enum NetworkServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .requestFailed(let error):
            return "Request failed with error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        }
    }
}

enum RSSFeedsError: LocalizedError {
    case feedExists

    var errorDescription: String? {
        switch self {
        case .feedExists:
            return "RSS feed already in list"
        }
    }
}

