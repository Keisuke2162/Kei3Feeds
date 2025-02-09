import Core
import Domain
import SwiftData
import SwiftUI

public struct FeedListView: View {
  @Query private var feeds: [FeedModel]
  @Environment(\.modelContext) private var context
  @StateObject var viewModel: FeedListViewModel

  public init(viewModel: FeedListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    ZStack {
      Color.blue
        .ignoresSafeArea()
      List {
        ForEach(viewModel.customFeeds.indices, id: \.self) { index in
          Text(viewModel.customFeeds[index].title)
        }
      }
    }
    .overlay {
      Text("Empty")
        .opacity(viewModel.customFeeds.isEmpty ? 1 : 0)
    }
    .onAppear {
      // viewModel.onAddFeedModel(feed: FeedModel(title: "yahoo", url: URL(string: "https://news.yahoo.co.jp/rss/topics/top-picks.xml")!), context: context)
      // viewModel.onAppear(feeds: feeds)
    }
    .onChange(of: feeds) { _, newValue in
      viewModel.onChangedFeeds(feeds: feeds)
    }
  }
}
