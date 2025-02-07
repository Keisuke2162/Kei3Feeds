import Foundation

public struct Article {
  let title: String
  let link: URL
  let publishedAt: Date
  let imageURL: URL
  let description: String

  public init(title: String, link: URL, publishedAt: Date, imageURL: URL, description: String) {
    self.title = title
    self.link = link
    self.publishedAt = publishedAt
    self.imageURL = imageURL
    self.description = description
  }
}
