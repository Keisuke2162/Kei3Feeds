import Foundation

public struct Feed {
  let title: String
  let url: String
  let lastUpdated: Date
  let imageURL: URL

  public init(title: String, url: String, lastUpdated: Date, imageURL: URL) {
    self.title = title
    self.url = url
    self.lastUpdated = lastUpdated
    self.imageURL = imageURL
  }
}
