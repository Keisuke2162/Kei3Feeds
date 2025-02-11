import Core
import SwiftData
import Foundation
import Domain

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
          let customFeed = try await feedRepository.fetchFeed(url: url)
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
          let feed = try await feedRepository.fetchFeed(url: url)
          recommendCustomFeeds.append(feed)
        } catch {
          continue
        }
      }
      isRecommendLoading = false
    }
  }
}
