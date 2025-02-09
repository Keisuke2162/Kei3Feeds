import Core
import Foundation

public protocol FeedRepositoryProtocol: AnyObject {
  func fetchFeed(url: URL) async throws -> CustomFeed
}
