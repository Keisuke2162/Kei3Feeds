import Foundation
import SwiftData

public struct CustomFeed: Sendable, Identifiable, Hashable {
  public let id: UUID
  public let title: String
  public let url: String
  public let lastUpdated: Date?
  public var updated: String? {
    lastUpdated?.toString()
  }
  public let imageURL: String?
  public let articles: [Article]

  public init(title: String, url: String, lastUpdated: Date?, imageURL: String?, articles: [Article]) {
    self.id = UUID()
    self.title = title
    self.url = url
    self.lastUpdated = lastUpdated
    self.imageURL = imageURL
    self.articles = articles
  }
}
