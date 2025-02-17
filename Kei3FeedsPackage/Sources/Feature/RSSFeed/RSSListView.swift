//
//  RSSListView.swift
//  Kei3FeedsPackage
//
//  Created by Kei on 2025/02/16.
//

import SwiftUI
import Core
import Domain
import SwiftData

@MainActor
public class RSSListViewModel: ObservableObject {
  let feedRepository: any FeedRepositoryProtocol
  @Published var rssList: [RSSFeedMetaData] = []
  @Published var sheetType: RSSPageType?
  // MEMO: onAppearを2回目移行実行させないためのフラグ。あんま使いたくない
  var isLoaded: Bool = false

  var newpapers: [RSSNewspaper] = []
  @Published var isNewsLoading = true
  // RSSArticleのキャッシュ
  var rssArticlesChaches: [String : [RSSArticle]] = [:]

  @Published var isRecommendLoading: Bool = false
  var recommendCustomFeeds: [RSSFeedMetaData] = []
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

  // 画面表示時にSwiftDataに保存した情報からRSS一覧を作成する
  public func onAppear(feeds: [FeedModel]) {
    if isLoaded { return }
    Task {
      try await fetchRSSMetadata(feeds)
      fetchNewspaper()
      fetchRecommends()
    }
  }

  // RSS一覧に追加
  public func onAddFeedModel(rss: RSSFeedMetaData, context: ModelContext) {
    let feedModel = FeedModel(title: rss.title, url: rss.url)
    rssList.append(rss)
    context.insert(feedModel)
  }

  // RSS一覧から削除
  public func onDeleteFeedModel(feed: FeedModel, rss: RSSFeedMetaData, context: ModelContext) {
    context.delete(feed)
    // TODO: titleの比較からurlの比較に修正したい
    rssList.removeAll { $0.title == rss.title }
  }

  public func onTapedSheetButton(type: RSSPageType) {
    sheetType = type
  }

  private func fetchRSSMetadata(_ feeds: [FeedModel]) async throws {
    rssList.removeAll()
    let urls = feeds.map { $0.url }
    for url in urls {
      let rss = try await feedRepository.fetchRSSMetadata(from: url)
      await MainActor.run {
        self.rssList.append(rss)
      }
    }
  }

  /// バックグラウンドで最新の記事まとめを作る
  /// その際[RSSArticle]を取得することになるのでRSSArticleListViewでのロードをしなくてもいいようにキャッシュするのもアリ
  private func fetchNewspaper() {
    Task {
      do {
        isNewsLoading = true
        var selectionArticles: [RSSArticle] = []
        // 登録している記事にRSSArticle配列を取得
        for rss in rssList {
          let articles = try await feedRepository.fetchArticles(url: rss.url)
          // TODO: ここでキャッシュ

          selectionArticles.append(contentsOf: articles.prefix(5))
        }
        // 取得したRSSArticle配列から最新の3記事ずつ取得してシャッフル
        selectionArticles.shuffle()
        // それぞれの記事のサムネイルとアイコンを取得
        let news = try await feedRepository.fetchNewspaper(articles: selectionArticles)
        newpapers = news
        print("テスト", news)
        isNewsLoading = false
      } catch {
        print("テスト", error.localizedDescription)
      }
    }
  }

  private func fetchRecommends() {
    Task {
      isRecommendLoading = true
      for url in recommendURLs {
        do {
          var feed = try await feedRepository.fetchRSSMetadata(from: url)
          recommendCustomFeeds.append(feed)
        } catch {
          continue
        }
      }
      isRecommendLoading = false
    }
  }
}

public struct RSSListView: View {
  @Query private var feeds: [FeedModel]
  
  @Environment(\.modelContext) private var context
  @StateObject var viewModel: RSSListViewModel
  
  public init(viewModel: RSSListViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      ZStack {
        List {
          ForEach(viewModel.rssList, id: \.id) { rss in
            NavigationLink {
              RSSArticleListView(viewModel: RSSArticleListViewModel(
                feedRepository: viewModel.feedRepository,
                rss: rss)
              )
            } label: {
              VStack(alignment: .leading, spacing: 8) {
                Text(rss.title)
                  .font(.subheadline)
                  .padding(.top, 4)
                HStack {
                  Text(rss.lastUpdatedString)
                    .font(.caption)
                  Spacer()
                }
              }
            }
          }
          .onDelete { indexSet in
            for index in indexSet {
              // FIXME: 要修正（titleで比較してるところurlにしたい）
              if let feed = feeds.first(where: { $0.url.absoluteString == viewModel.rssList[index].title }) {
                viewModel.onDeleteFeedModel(feed: feed, rss: viewModel.rssList[index], context: context)
              }
            }
          }
        }
        
        VStack {
          Spacer()
          HStack(spacing: 46) {
            Button {
              viewModel.sheetType = .setting
            } label: {
              Image(systemName: "gear")
                .padding(8)
                .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.cyan)
            .clipShape(.rect(cornerRadius: 8))
            
            Button {
              viewModel.sheetType = .recommend
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
              viewModel.sheetType = .newspaper
            } label: {
              Image(systemName: "newspaper")
                .padding(8)
                .foregroundStyle(viewModel.isNewsLoading ? .gray : .white)
            }
            .frame(width: 56, height: 56)
            .background(viewModel.isNewsLoading ? .gray : .cyan)
            .clipShape(.rect(cornerRadius: 8))
            .disabled(viewModel.isNewsLoading)
          }
          .padding(.bottom, 16)
        }
      }
    }
    .onAppear {
      viewModel.onAppear(feeds: feeds)
    }
    .fullScreenCover(item: $viewModel.sheetType) { type in
      switch type {
      case .setting:
        EmptyView()
      case .recommend:
        RSSRecommendView(recommends: viewModel.recommendCustomFeeds, onAddFeed: viewModel.onAddFeedModel(rss:context:))
      case .newspaper:
        RSSNewspaperView(newspapers: viewModel.newpapers)
      }
    }
  }
}
