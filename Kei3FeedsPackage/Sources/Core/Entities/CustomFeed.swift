import Foundation
import SwiftData

public struct CustomFeed: Sendable, Identifiable {
  public let id: String
  public let title: String
  public let url: String
  public let lastUpdated: Date?
  public let imageURL: String?
  public let articles: [Article]

  public init(id: String, title: String, url: String, lastUpdated: Date?, imageURL: String?, articles: [Article]) {
    self.id = id
    self.title = title
    self.url = url
    self.lastUpdated = lastUpdated
    self.imageURL = imageURL
    self.articles = articles
  }
}
