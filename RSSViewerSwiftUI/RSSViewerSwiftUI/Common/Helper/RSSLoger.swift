//
//  RSSLoger.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 09.03.2025..
//

import Foundation

class RSSLogger {
    enum Level: String {
        case debug, info, error
    }

    static func log(_ level: Level, message: String, file: String = #file, function: String = #function, line: Int = #line) {
            // Extract filename from path
        let filename = URL(fileURLWithPath: file).lastPathComponent

            // Create timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())

            // Format log message with metadata
        let logMessage = "[\(timestamp)] [\(level.rawValue.uppercased())] [\(filename):\(line) \(function)] \(message)"

            // In development, print to console
#if DEBUG
        print(logMessage)
#endif
            // In production, you might write to a file or send to a logging service
            // saveToLogFile(logMessage)
    }
}
