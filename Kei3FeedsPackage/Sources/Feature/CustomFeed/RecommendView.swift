import Core
import Domain
import SwiftData
import SwiftUI

public struct RecommendView: View {
  @Query private var feeds: [FeedModel]
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) var dismiss
  let recommendFeeds: [CustomFeed]

  // FIXME: クロージャでやるかViewModelでやるかFeedListViewModelでやるか設計に迷ってる
  let onAddFeed: (CustomFeed, ModelContext) -> Void

  public init(recommendFeeds: [CustomFeed], onAddFeed: @escaping (CustomFeed, ModelContext) -> Void) {
    self.recommendFeeds = recommendFeeds
    self.onAddFeed = onAddFeed
  }

  public var body: some View {
    ZStack {
      List {
        ForEach(recommendFeeds) { feed in
          HStack {
            Text(feed.title)
              .font(.callout)
            Spacer()
            if let url = URL(string: feed.url), !(feeds.contains(where: { $0.url == url })) {
              Button {
                onAddFeed(feed, context)
              } label: {
                Image(systemName: "square.and.arrow.down.fill")
                  .frame(width: 24, height: 24)
              }
            } else {
              Image(systemName: "checkmark")
                .frame(width: 24, height: 24)
            }
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 16)
        }
      }
    }
  }
}
