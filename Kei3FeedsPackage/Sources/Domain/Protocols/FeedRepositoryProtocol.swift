import Core
import Foundation

public protocol FeedRepositoryProtocol: AnyObject, Sendable, ObservableObject {
  func fetchFeed(url: URL) async throws -> CustomFeed
  func fetchOGP(articles: [Article]) async throws -> [Article]
  func fetchRSSMetadata(from url: URL) async throws -> RSSFeedMetaData
  func fetchArticles(url: URL) async throws -> [RSSArticle]
  func fetchNewspaper(articles: [RSSArticle]) async throws -> [RSSNewspaper]
}
