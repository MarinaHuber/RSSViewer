//
//  RSSLoger.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 09.03.2025..
//

import Foundation

protocol LoggerProtocol {
    func log(level: RSSLogger.Level, message: String, file: String, function: String, line: Int)
}

class RSSLogger {
    enum Level: String {
        case debug, info, error
    }

    static let shared = RSSLogger()
    private let implementation: LoggerProtocol
    
    private init(implementation: LoggerProtocol = DefaultLoggerImplementation()) {
        self.implementation = implementation
    }

    func log(_ level: Level, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        implementation.log(level: level, message: message, file: file, function: function, line: line)
    }
        // EXTEND TO convenience methods

}

struct DefaultLoggerImplementation: LoggerProtocol {
    func log(level: RSSLogger.Level, message: String, file: String, function: String, line: Int) {
        let filename = URL(fileURLWithPath: file).lastPathComponent

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())

        let logMessage = "[\(timestamp)] [\(level.rawValue.uppercased())] [\(filename):\(line) \(function)] \(message)"

#if DEBUG
        print(logMessage)
#endif
            // Additional logging destinations for production
    }
}
