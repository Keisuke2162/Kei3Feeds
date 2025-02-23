import Core
import Domain
import SwiftData
import SwiftUI

public struct RSSRecommendView: View {
  @Query private var feeds: [FeedModel]
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) var dismiss
  let recommends: [RSSFeedMetaData]

  // FIXME: クロージャでやるかViewModelでやるかFeedListViewModelでやるか設計に迷ってる
  let onAddFeed: (RSSFeedMetaData, ModelContext) -> Void
  let onDeleteFeed: (FeedModel, ModelContext) -> Void

  public init(recommends: [RSSFeedMetaData], onAddFeed: @escaping (RSSFeedMetaData, ModelContext) -> Void, onDeleteFeed: @escaping (FeedModel, ModelContext) -> Void) {
    self.recommends = recommends
    self.onAddFeed = onAddFeed
    self.onDeleteFeed = onDeleteFeed
  }

  public var body: some View {
    ZStack {
      ScrollView {
        ForEach(recommends) { feed in
          let isContaintsFeed = feeds.contains(where: { $0.url == feed.url })
          HStack {
            isContaintsFeed ? Color.yellow.frame(width: 16) : Color.gray.frame(width: 16)
            Text(feed.title)
              .font(.subheadline).bold()
              .multilineTextAlignment(.leading)
              .foregroundStyle(.white)
              .padding(.vertical, 24)
            Spacer()
            Toggle("", isOn: Binding(
              get: { isContaintsFeed },
              set: { newValue in
                if newValue {
                  onAddFeed(feed, context)
                } else {
                  if let deleteFeed = feeds.first(where: { $0.url == feed.url }) {
                    onDeleteFeed(deleteFeed, context)
                  }
                }
              }
            ))
            .frame(maxWidth: 64)
            .padding(.trailing, 16)
          }
          .clipShape(.rect(cornerRadius: 8))
          .overlay {
            RoundedRectangle(cornerRadius: 8)
              .stroke(isContaintsFeed ? .yellow : .gray, lineWidth: 2)
          }
          .padding(.vertical, 8)
        }
      }
      .padding(24)
      .scrollIndicators(.hidden)
    }
  }
}
