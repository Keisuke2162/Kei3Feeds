import Core
import SwiftData
import Foundation
import Domain

@MainActor
public class SearchViewModel: ObservableObject {
  @Published var searchResultCustomFeed: CustomFeed?
  @Published var isLoading: Bool = false

  let feedRepository: any FeedRepositoryProtocol
  let feeds: [FeedModel]
  let onAddFeed: (CustomFeed, ModelContext) -> Void
  
  public init(feedRepository: any FeedRepositoryProtocol, feeds: [FeedModel], onAddFeed: @escaping (CustomFeed, ModelContext) -> Void) {
    self.feedRepository = feedRepository
    self.feeds = feeds
    self.onAddFeed = onAddFeed
  }

  public func onTapSearchButton(text: String) {
    searchResultCustomFeed = nil
    guard let url = URL(string: text) else { return }
    Task {
      isLoading = true
      do {
        let feed = try await feedRepository.fetchFeed(url: url)
        isLoading = false
        searchResultCustomFeed = feed
      } catch {
      }
    }
  }
}
