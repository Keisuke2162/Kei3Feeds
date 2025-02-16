import Foundation

public struct RSSFeed: Sendable, Identifiable, Hashable, Codable {
  public let id: UUID
  public let title: String
  public let url: String
  public let lastUpdated: Date?
  public var updated: String? {
    lastUpdated?.toString()
  }
  public let imageURL: String?

  public init(title: String, url: String, lastUpdated: Date?, imageURL: String?) {
    self.id = UUID()
    self.title = title
    self.url = url
    self.lastUpdated = lastUpdated
    self.imageURL = imageURL
  }
}
