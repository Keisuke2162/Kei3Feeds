public enum RSSPageType: Identifiable {
  case setting
  case recommend
  case newspaper

  public var id: String {
    switch self {
    case .setting:
      "setting"
    case .recommend:
      "recommend"
    case .newspaper:
      "newspaper"
    }
  }
}
