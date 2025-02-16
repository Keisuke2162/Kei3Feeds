import Foundation

public struct RSSFeedMetaData: Sendable, Identifiable, Hashable {
  public var id = UUID()
  public let title: String
  public let lastUpdated: Date?
  public var lastUpdatedString: String {
    lastUpdated?.toString() ?? ""
  }

  public init(title: String, lastUpdated: Date?) {
    self.title = title
    self.lastUpdated = lastUpdated
  }
}
