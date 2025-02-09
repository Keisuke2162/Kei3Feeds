import Core
import Domain
import SwiftData
import SwiftUI

public struct FeedListView: View {
  // @Query private var feeds: [FeedModel]
  
  // TODO: 仮
  let mockFeeds: [FeedModel] = [
    FeedModel(title: "ITmedia", url: URL(string: "https://rss.itmedia.co.jp/rss/2.0/itmedia_all.xml")!),
    FeedModel(title: "domesaka", url: URL(string: "https://blog.domesoccer.jp/feed")!),
    FeedModel(title: "gekisaka", url: URL(string: "https://web.gekisaka.jp/feed")!),
    FeedModel(title: "giga", url: URL(string: "https://gigazine.net/news/rss_2.0/")!),
    FeedModel(title: "giz", url: URL(string: "http://www.gizmodo.jp/atom.xml")!),
    FeedModel(title: "it", url: URL(string: "https://rss.itmedia.co.jp/rss/2.0/ait.xml")!),
    FeedModel(title: "tech", url: URL(string: "https://techcrunch.com/feed/")!),
    FeedModel(title: "kabu", url: URL(string: "https://kabumatome.doorblog.jp/index.rdf")!),
    FeedModel(title: "hamu", url: URL(string: "http://hamusoku.com/index.rdf")!),
  ]

  @Environment(\.modelContext) private var context
  @StateObject var viewModel: FeedListViewModel

  public init(viewModel: FeedListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      List {
        ForEach(viewModel.customFeeds, id: \.id) { feed in
          NavigationLink {
            ArticleListView(articles: feed.articles)
          } label: {
            VStack(alignment: .leading, spacing: 8) {
              Text(feed.title)
                .font(.subheadline)
                .padding(.top, 4)
              HStack {
                Spacer()
                Text(feed.updated ?? "")
                  .font(.caption)
              }
            }
          }
        }
      }
      .overlay {
        Text("Empty")
          .opacity(viewModel.customFeeds.isEmpty ? 1 : 0)
      }
      .onAppear {
        // viewModel.onAddFeedModel(feed: FeedModel(title: "yahoo", url: URL(string: "https://news.yahoo.co.jp/rss/topics/top-picks.xml")!), context: context)
        viewModel.onAppear(feeds: mockFeeds)
      }
      .onChange(of: mockFeeds) { _, newValue in
        viewModel.onChangedFeeds(feeds: mockFeeds)
      }
    }
  }
}
