import Core
import Data
import Feature
import SwiftUI
import SwiftData

@main
struct Kei3FeedsApp: App {
//  @StateObject var feedRepository = FeedRepository()
  let feedRepository = FeedRepository()
  
  var body: some Scene {
    WindowGroup {
      // FeedListView(viewModel: FeedListViewModel(feedRepository: feedRepository))
      RSSListView(viewModel: RSSListViewModel(feedRepository: feedRepository))
    }
    .modelContainer(for: FeedModel.self)
  }
}
