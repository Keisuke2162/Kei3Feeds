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

  public init(feedRepository: any FeedRepositoryProtocol) {
    self.feedRepository = feedRepository
  }

  public func onAppear(feeds: [FeedModel]) {
    if !isLoaded {
      makeCustomFeeds(feeds: feeds)
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
}
