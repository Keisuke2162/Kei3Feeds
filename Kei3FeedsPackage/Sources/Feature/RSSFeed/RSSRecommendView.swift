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
      List {
        ForEach(recommends) { feed in
          HStack {
            Text(feed.title)
              .font(.headline)
            Spacer()
            let isContaintsFeed = feeds.contains(where: { $0.url == feed.url })
            Button {
              if isContaintsFeed {
                if let deleteFeed = feeds.first(where: { $0.url == feed.url }) {
                  onDeleteFeed(deleteFeed, context)
                }
              } else {
                onAddFeed(feed, context)
              }
            } label: {
              Image(systemName: isContaintsFeed ? "checkmark" : "arrow.down")
                .frame(width: 16, height: 16)
            }
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 16)
        }
      }

      VStack {
        Spacer()
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(.white)
            .padding(8)
        }
        .frame(width: 56, height: 56)
        .background(.indigo)
        .clipShape(.rect(cornerRadius: 28))
      }
    }
  }
}
