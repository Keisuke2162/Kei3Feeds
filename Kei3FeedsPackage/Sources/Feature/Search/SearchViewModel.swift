import Core
import SwiftData
import Foundation
import Domain

@MainActor
public class SearchViewModel: ObservableObject {
  @Published var searchResultCustomFeed: CustomFeed?
  @Published var isLoading: Bool = false

  let feedRepository: any FeedRepositoryProtocol
  
  public init(feedRepository: any FeedRepositoryProtocol) {
    self.feedRepository = feedRepository
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

  public func onTapRegisterButton(context: ModelContext) {
    guard let customFeed = searchResultCustomFeed, let url = URL(string: customFeed.url) else {
      return
    }
    let feedModel = FeedModel(title: customFeed.title, url: url)
    context.insert(feedModel)
  }
}
