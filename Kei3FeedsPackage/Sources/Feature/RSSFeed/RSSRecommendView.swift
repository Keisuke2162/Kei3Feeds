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

  public init(recommends: [RSSFeedMetaData], onAddFeed: @escaping (RSSFeedMetaData, ModelContext) -> Void) {
    self.recommends = recommends
    self.onAddFeed = onAddFeed
  }

  public var body: some View {
    ZStack {
      List {
        ForEach(recommends) { feed in
          HStack {
            Text(feed.title)
              .font(.headline)
            Spacer()
            if !(feeds.contains(where: { $0.url == feed.url })) {
              Button {
                onAddFeed(feed, context)
              } label: {
                Image(systemName: "arrow.down")
                  .frame(width: 16, height: 16)
              }
            } else {
              Image(systemName: "checkmark")
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
