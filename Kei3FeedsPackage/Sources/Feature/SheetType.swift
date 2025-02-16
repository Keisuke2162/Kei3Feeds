public enum SheetType: Identifiable {
  case setting
  case recommend
  case search

  public var id: String {
    switch self {
    case .setting:
      "setting"
    case .recommend:
      "recommend"
    case .search:
      "search"
    }
  }
}
