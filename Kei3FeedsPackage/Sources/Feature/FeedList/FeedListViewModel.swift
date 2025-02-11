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
  
  public func onAddFeedModel(feed: FeedModel, context: ModelContext) {
    context.insert(feed)
  }

  public func onDeleteFeedModel(feed: FeedModel, context: ModelContext) {
    context.delete(feed)
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
