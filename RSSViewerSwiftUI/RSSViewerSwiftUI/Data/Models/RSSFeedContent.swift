
import Foundation

struct RSSFeedContent: Codable, Hashable {
    var title: String?
    var description: String?
    var linkURL: URL?
    var imageURL: URL?
    var items = [RSSItem]()
}
