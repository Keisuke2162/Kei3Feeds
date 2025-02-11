import Foundation

public struct RSSSamples: Identifiable {
  public var id: UUID = UUID()
  let title: String
  let url: URL
  
  public init(id: UUID, title: String, url: URL) {
    self.id = id
    self.title = title
    self.url = url
  }
}

