import Foundation
import SwiftData

@Model
public final class FeedModel: Identifiable {
  @Attribute(.unique) public var id: UUID
  public var title: String
  public var url: URL

  public init(title: String, url: URL) {
    self.id = UUID()
    self.title = title
    self.url = url
  }
}
