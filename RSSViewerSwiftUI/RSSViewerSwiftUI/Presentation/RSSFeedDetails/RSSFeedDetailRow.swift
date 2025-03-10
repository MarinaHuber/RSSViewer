//
//  RSSFeedDetailRow.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import SwiftUI

struct RSSFeedItemRow: View {
    let item: RSSItem
    let imageSize: CGFloat = 120

    var body: some View {
        HStack(alignment: .top,spacing: 16) {
            AsyncImage(url: item.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(8)

            } placeholder: {
                ZStack {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .cornerRadius(8)
                        .frame(width: imageSize, height: imageSize)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(4)

                Text(item.description ?? "No description")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            .environment(\._lineHeightMultiple, 0.8)
            .frame(maxWidth: .infinity, maxHeight: imageSize, alignment: .leading)
        }
        .padding()
    }
}

#Preview {
    RSSFeedItemRow(item: RSSItem(title: "Title", description: "Description", imageURL: URL(string: "www.image.url")))
}

