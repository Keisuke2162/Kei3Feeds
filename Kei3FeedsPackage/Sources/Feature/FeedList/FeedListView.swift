import Core
import Domain
import SwiftData
import SwiftUI

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

public struct FeedListView: View {
  @Query private var feeds: [FeedModel]
  @State var sheetType: SheetType?

  @Environment(\.modelContext) private var context
  @StateObject var viewModel: FeedListViewModel

  public init(viewModel: FeedListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      ZStack {
        List {
          ForEach(viewModel.customFeeds, id: \.id) { feed in
            NavigationLink {
//              ArticleListView(articles: feed.articles)
              ArticleRichPageView(articles: feed.articles)
            } label: {
              VStack(alignment: .leading, spacing: 8) {
                Text(feed.title)
                  .font(.subheadline)
                  .padding(.top, 4)
                HStack {
                  Spacer()
                  Text(feed.updated ?? "")
                    .font(.caption)
                }
              }
            }
          }
          .onDelete { indexSet in
            for index in indexSet {
              // FIXME: ViewModelでdeleteする意味ある？
              if let feed = feeds.first(where: { $0.url.absoluteString == viewModel.customFeeds[index].url }) {
                viewModel.onDeleteFeedModel(feed: feed, customFeed: viewModel.customFeeds[index], context: context)
              }
            }
          }
        }
        .overlay {
          Text("Empty")
            .opacity(viewModel.customFeeds.isEmpty ? 1 : 0)
        }
        .onAppear {
          viewModel.onAppear(feeds: feeds)
        }
        
        VStack {
          Spacer()
          
          HStack(spacing: 46) {
            Button {
              // TODO: 設定画面へ遷移
            } label: {
              Image(systemName: "gear")
                .padding(8)
                .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.cyan)
            .clipShape(.rect(cornerRadius: 8))
            
            Button {
              sheetType = .recommend
            } label: {
              Image(systemName: "list.triangle")
                .padding(8)
                .foregroundStyle(viewModel.isRecommendLoading ? .gray : .white)
            }
            .frame(width: 56, height: 56)
            .background(viewModel.isRecommendLoading ? .gray : .cyan)
            .clipShape(.rect(cornerRadius: 8))
            .disabled(viewModel.isRecommendLoading)

            Button {
              sheetType = .search
            } label: {
              Image(systemName: "magnifyingglass")
                .padding(8)
                .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.cyan)
            .clipShape(.rect(cornerRadius: 8))
          }
          .padding(.bottom, 16)
        }
      }
    }
    .sheet(item: $sheetType) { type in
      switch type {
      case .setting:
        EmptyView()
      case .recommend:
        RecommendView(recommendFeeds: viewModel.recommendCustomFeeds, onAddFeed: viewModel.onAddFeedModel(customFeed:context:))
      case .search:
        SearchView(viewModel: SearchViewModel(feedRepository: viewModel.feedRepository, feeds: feeds, onAddFeed: viewModel.onAddFeedModel(customFeed:context:)))
      }
    }
  }
}
