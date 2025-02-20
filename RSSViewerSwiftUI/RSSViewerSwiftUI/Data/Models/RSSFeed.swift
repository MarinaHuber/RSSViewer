
import Foundation

struct RSSFeed: Codable, Hashable, Identifiable {
    var id: String { path }
    let path: String
    var content: RSSFeedContent
    var newItemCount    = 0
}

extension RSSFeed: Equatable {
    static func == (lhs: RSSFeed, rhs: RSSFeed) -> Bool {
        lhs.path == rhs.path &&
        lhs.content.items == rhs.content.items
    }
}
