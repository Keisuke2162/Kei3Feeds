import Core
import SwiftData
import Foundation
import Domain

@MainActor
public class FeedListViewModel: ObservableObject {
  let feedRepository: any FeedRepositoryProtocol
  @Published var customFeeds: [CustomFeed] = []

  public init(feedRepository: any FeedRepositoryProtocol) {
    self.feedRepository = feedRepository
  }

  public func onAppear(feeds: [FeedModel]) {
    makeCustomFeeds(feeds: feeds)
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
    let urls = feeds.map { $0.url }
    
    // TODO: ここどうなの？
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
