//
//  RSSFeedRowView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import SwiftUI

struct RSSFeedRowView: View {
    var feed: RSSFeed

    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: feed.content.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } placeholder: {
                ZStack {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }
            .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(feed.content.title ?? "")
                    .font(.headline)
                    .lineLimit(1)

                Text(feed.content.description ?? "No description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
//    RSSFeedRowView(feed: .constant(RSSFeed(path: "",
//                                           content: RSSFeedContent(title: "Title",
//                                                                   description: "Description",
//                                                                   imageURL: URL(string: "www.image.url")))))
}
