import Foundation
import SwiftData

@Model
public final class FeedModel: Identifiable {
  @Attribute(.unique) public var id: String
  public var title: String
  public var url: URL

  public init(title: String, url: URL) {
    self.id = UUID().uuidString
    self.title = title
    self.url = url
  }
}
