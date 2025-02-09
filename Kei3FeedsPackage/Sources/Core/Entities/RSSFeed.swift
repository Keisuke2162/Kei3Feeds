import Foundation
import SwiftData

public struct CustomFeed {
  let title: String
  let url: String
  let lastUpdated: Date?
  let imageURL: String?
  let articles: [Article]

  public init(title: String, url: String, lastUpdated: Date?, imageURL: String?, articles: [Article]) {
    self.title = title
    self.url = url
    self.lastUpdated = lastUpdated
    self.imageURL = imageURL
    self.articles = articles
  }
}
