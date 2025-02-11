import Foundation

public struct RecommendRSS: Identifiable {
  public var id: UUID = UUID()
  public let title: String
  public let url: URL
  
  public init(title: String, url: URL) {
    self.title = title
    self.url = url
  }
}

