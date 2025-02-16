import Foundation

public struct RSSArticle: Identifiable, Sendable, Hashable {
  public let id = UUID()
  public let title: String
  public let link: URL?
  public let pubDate: Date?

  public init(title: String, link: URL?, pubDate: Date?) {
    self.title = title
    self.link = link
    self.pubDate = pubDate
  }
}
