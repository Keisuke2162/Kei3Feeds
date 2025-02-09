import Core
import Foundation

public protocol FeedRepositoryProtocol: AnyObject, Sendable, ObservableObject {
  func fetchFeed(url: URL) async throws -> CustomFeed
}
