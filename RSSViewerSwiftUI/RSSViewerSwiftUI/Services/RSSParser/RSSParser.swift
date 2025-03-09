//
//  RSSParser.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import Foundation

class RSSParser: NSObject {
    private enum RSSKeys: String {
        case title, description, url, item, link, image
        case media = "media:thumbnail"
    }

    private enum RSSAttributes: String {
        case url
    }

    typealias RSSFeedResult = Result<RSSFeedContent, RSSParserError>

    private var feed = RSSFeedContent()
    private var currentItem: RSSItem?
    private var currentElement = ""
    private var currentText = ""

    private var completion: ((RSSFeedResult) -> Void)?

    func parseRSS(data: Data, completion: @escaping (RSSFeedResult) -> Void) {
        self.completion = completion

        resetInstanceProperties()

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }

    func parseRSS(data: Data) async throws -> RSSFeedContent {
        try await withCheckedThrowingContinuation { continuation in
            parseRSS(data: data) { result in
                continuation.resume(with: result)
            }
        }
    }

    func resetInstanceProperties() {
        feed = RSSFeedContent()
        currentItem = nil
        currentElement = ""
        currentText = ""
    }
}

extension RSSParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""

        switch RSSKeys(rawValue: elementName) {
        case .item:
            currentItem = RSSItem()

        case .media:
            guard currentItem?.imageURL == nil else { break }
            currentItem?.imageURL = URL(string: attributeDict[RSSAttributes.url.rawValue] ?? "")

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !trimmed(string).isEmpty else { return }
        currentText += trimmed(string)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let decodedString = String(data: CDATABlock, encoding: .utf8) else {
            completion?(.failure(.invalidCDATAContent))
            RSSLogger.shared.log(.error, message: "invalidCDATAContent")
            parser.abortParsing()
            return
        }
        currentText += trimmed(decodedString)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch RSSKeys(rawValue: elementName) {
        case .title:
            guard currentItem != nil else {
                feed.title = !currentText.isEmpty ? currentText : nil
                return
            }
            currentItem?.title = currentText

        case .description:
            guard currentItem != nil else {
                feed.description = !currentText.isEmpty ? currentText : nil
                return
            }
            currentItem?.description = currentText

        case .url:
            feed.imageURL = validateAndCreateURL(from: currentText, parser: parser)

        case .image:
            currentItem?.imageURL = validateAndCreateURL(from: currentText, parser: parser)

        case .link:
            if currentItem == nil {
                feed.linkURL = validateAndCreateURL(from: currentText, parser: parser)
            } else {
                    // Item link URL - critical for item functionality
                currentItem?.linkURL = validateAndCreateURL(from: currentText, parser: parser)
            }

        case .item:
            if let item = currentItem {
                feed.items.append(item)
            }
            currentItem = nil

        default:
            break
        }

    }

    func parserDidEndDocument(_ parser: XMLParser) {
        if feed.title == nil {
            completion?(.failure(.missingRequiredElement("title")))
            return
        }
        completion?(.success(feed))
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        completion?(.failure(.errorParsingXML(underlying: parseError)))
    }

    private func trimmed(_ string: String) -> String {
        string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validateAndCreateURL(from string: String, parser: XMLParser? = nil) -> URL? {
        guard !string.isEmpty else { return nil }

        guard let url = URL(string: string) else {
            let error = RSSParserError.malformedURL(string)

                // Log error parser
            RSSLogger.shared.log(.error, message: error.debugDescription)

            completion?(.failure(error))
            parser?.abortParsing()
            return nil
        }
        return url
    }
}

enum RSSParserErrorTest: LocalizedError {
    case errorParsingXML

    var errorDescription: String? {
        switch self {
        case .errorParsingXML:
            return "URL link does not contain a valid RSS feed"
        }
    }
}

enum RSSParserError: LocalizedError {
    case errorParsingXML(underlying: Error? = nil)
    case malformedURL(String)
    case missingRequiredElement(String)
    case invalidCDATAContent

    var errorDescription: String? {
        switch self {
        case .errorParsingXML:
            return "Unable to read the RSS feed. The content might be corrupted or in an unsupported format."
        case .malformedURL(let urlString):
            return "The feed contains an invalid web address: \(urlString)"
        case .missingRequiredElement(let element):
            return "The feed is missing required information: \(element)"
        case .invalidCDATAContent:
            return "Some content in the feed couldn't be properly decoded."
        }
    }

        // Technical details for logging
    var debugDescription: String {
        switch self {
        case .errorParsingXML(let error):
            let detail = error?.localizedDescription ?? "Unknown parsing error"
            return "XML Parser error: \(detail)"
        case .malformedURL(let urlString):
            return "Malformed URL encountered: '\(urlString)'"
        case .missingRequiredElement(let element):
            return "Required RSS element missing: '\(element)'"
        case .invalidCDATAContent:
            return "Failed to decode CDATA content"
        }
    }
}
