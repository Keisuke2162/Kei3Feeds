import Core
import Domain
import SwiftData
import SwiftUI

@MainActor
public class FeedListViewModel: ObservableObject {
  let feedRepository: any FeedRepositoryProtocol
  @Published var customFeeds: [CustomFeed] = []
  
  // MEMO: onAppearを2回目移行実行させないためのフラグ。あんま使いたくない
  var isLoaded: Bool = false
  
  // FIXME: おすすめ用のURL、おすすめ開くたびにロードしたくないのでこの画面でバックグラウンド取得しておく（本来はRootViewでやりたい）
  @Published var isRecommendLoading: Bool = false
  var recommendCustomFeeds: [CustomFeed] = []
  let recommendURLs: [URL] = [
    URL(string: "https://news.yahoo.co.jp/rss/topics/top-picks.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/domestic.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/world.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/business.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/entertainment.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/sports.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/it.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/science.xml")!,
    URL(string: "https://news.yahoo.co.jp/rss/topics/local.xml")!,
    URL(string: "https://rss.itmedia.co.jp/rss/2.0/itmedia_all.xml")!,
    URL(string: "https://web.gekisaka.jp/feed")!,
    URL(string: "https://number.bunshun.jp/list/rsssports")!,
    URL(string: "https://toyokeizai.net/list/feed/rss")!,
    URL(string: "https://bunshun.jp/list/feed/rss")!,
    URL(string: "https://b.hatena.ne.jp/hotentry.rss")!,
    URL(string: "https://gori.me/feed")!,
    URL(string: "https://www.lifehacker.jp/feed/index.xml")!,
    URL(string: "https://gigazine.net/news/rss_2.0/")!,
    URL(string: "https://zenn.dev/feed")!,
    URL(string: "https://rss.itmedia.co.jp/rss/2.0/ait.xml")!,
    URL(string: "http://www.gizmodo.jp/atom.xml")!,
    URL(string: "http://hamusoku.com/index.rdf")!,
    URL(string: "https://blog.domesoccer.jp/feed")!,
    URL(string: "https://prtimes.jp/index.rdf")!,
  ]

  public init(feedRepository: any FeedRepositoryProtocol) {
    self.feedRepository = feedRepository
  }

  public func onAppear(feeds: [FeedModel]) {
    if !isLoaded {
      makeCustomFeeds(feeds: feeds)
      makeRecommendFeeds()
      isLoaded = true
    }
  }

  public func onChangedFeeds(feeds: [FeedModel]) {
    makeCustomFeeds(feeds: feeds)
  }
  
  public func onAddFeedModel(customFeed: CustomFeed, context: ModelContext) {
    guard let url = URL(string: customFeed.url) else { return }
    let feedModel = FeedModel(title: customFeed.title, url: url)
    customFeeds.append(customFeed)
    context.insert(feedModel)
  }

  public func onDeleteFeedModel(feed: FeedModel, customFeed: CustomFeed, context: ModelContext) {
    context.delete(feed)
    customFeeds.removeAll { $0.url == customFeed.url }
  }

  private func makeCustomFeeds(feeds: [FeedModel]) {
    customFeeds.removeAll()
    let urls = feeds.map { $0.url }
    // FIXME: ここどうなの？（async let で全部取得してから描画でも）
    for url in urls {
      Task {
        do {
          var customFeed = try await feedRepository.fetchFeed(url: url)
          customFeed.articles = try await feedRepository.fetchOGP(articles: customFeed.articles)
          await MainActor.run {
            self.customFeeds.append(customFeed)
          }
        } catch {
          // TODO: Error
        }
      }
    }
  }

  private func makeRecommendFeeds() {
    Task {
      isRecommendLoading = true
      for url in recommendURLs {
        do {
          var feed = try await feedRepository.fetchFeed(url: url)
          feed.articles = try await feedRepository.fetchOGP(articles: feed.articles)
          recommendCustomFeeds.append(feed)
        } catch {
          continue
        }
      }
      isRecommendLoading = false
    }
  }
}


public struct FeedListView: View {
  @Query private var feeds: [FeedModel]
  @State var sheetType: SheetType?

  @Environment(\.modelContext) private var context
  @StateObject var viewModel: FeedListViewModel

  public init(viewModel: FeedListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      ZStack {
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
          .onDelete { indexSet in
            for index in indexSet {
              // FIXME: ViewModelでdeleteする意味ある？
              if let feed = feeds.first(where: { $0.url.absoluteString == viewModel.customFeeds[index].url }) {
                viewModel.onDeleteFeedModel(feed: feed, customFeed: viewModel.customFeeds[index], context: context)
              }
            }
          }
        }
        .overlay {
          Text("Empty")
            .opacity(viewModel.customFeeds.isEmpty ? 1 : 0)
        }
        .onAppear {
          viewModel.onAppear(feeds: feeds)
        }
        
        VStack {
          Spacer()
          
          HStack(spacing: 46) {
            Button {
              // TODO: 設定画面へ遷移
            } label: {
              Image(systemName: "gear")
                .padding(8)
                .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.cyan)
            .clipShape(.rect(cornerRadius: 8))
            
            Button {
              sheetType = .recommend
            } label: {
              Image(systemName: "list.triangle")
                .padding(8)
                .foregroundStyle(viewModel.isRecommendLoading ? .gray : .white)
            }
            .frame(width: 56, height: 56)
            .background(viewModel.isRecommendLoading ? .gray : .cyan)
            .clipShape(.rect(cornerRadius: 8))
            .disabled(viewModel.isRecommendLoading)

            Button {
              sheetType = .search
            } label: {
              Image(systemName: "magnifyingglass")
                .padding(8)
                .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.cyan)
            .clipShape(.rect(cornerRadius: 8))
          }
          .padding(.bottom, 16)
        }
      }
    }
    .sheet(item: $sheetType) { type in
      switch type {
      case .setting:
        EmptyView()
      case .recommend:
        RecommendView(recommendFeeds: viewModel.recommendCustomFeeds, onAddFeed: viewModel.onAddFeedModel(customFeed:context:))
      case .search:
        SearchView(viewModel: SearchViewModel(feedRepository: viewModel.feedRepository, feeds: feeds, onAddFeed: viewModel.onAddFeedModel(customFeed:context:)))
      }
    }
  }
}
