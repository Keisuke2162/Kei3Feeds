import Foundation

public struct RSSFeedMetaData: Sendable, Identifiable, Hashable {
  public var id = UUID()
  public let title: String
  public let lastUpdated: Date?
  public var lastUpdatedString: String {
    lastUpdated?.toString() ?? "----/--/--"
  }
  public let url: URL

  public init(title: String, lastUpdated: Date?, url: URL) {
    self.title = title
    self.lastUpdated = lastUpdated
    self.url = url
  }
}
