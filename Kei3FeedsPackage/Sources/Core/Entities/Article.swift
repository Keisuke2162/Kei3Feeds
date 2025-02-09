import Foundation

public struct Article {
  public let title: String
  public let link: String
  public let publishedAt: Date?
  public let imageURL: String?
  public let description: String

  public init(title: String, link: String, publishedAt: Date?, imageURL: String?, description: String) {
    self.title = title
    self.link = link
    self.publishedAt = publishedAt
    self.imageURL = imageURL
    self.description = description
  }
}
