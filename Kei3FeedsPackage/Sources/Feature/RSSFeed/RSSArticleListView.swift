import Core
import Domain
import SwiftUI

@MainActor
public class RSSArticleListViewModel: ObservableObject {
  let feedRepository: any FeedRepositoryProtocol
  let rss: RSSFeedMetaData
  @Published var articles: [RSSArticle] = []
  
  public init(feedRepository: any FeedRepositoryProtocol, rss: RSSFeedMetaData) {
    self.feedRepository = feedRepository
    self.rss = rss
  }
  
  // 画面表示時にSwiftDataに保存した情報からRSS一覧を作成する
  public func onAppear() {
    Task {
      articles = try await feedRepository.fetchArticles(url: rss.url)
    }
  }
}

public struct RSSArticleListView: View {
  @Environment(\.colorScheme) var colorScheme
  @StateObject var viewModel: RSSArticleListViewModel

  public init(viewModel: RSSArticleListViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    ZStack {
      List {
        ForEach(viewModel.articles.indices, id: \.self) { index in
          if let link = viewModel.articles[index].link {
            Link(destination: link) {
              Text(viewModel.articles[index].title)
                .font(.headline)
                .lineSpacing(4)
                .padding(.top, 4)
              HStack {
                Spacer()
                Text(viewModel.articles[index].pubDate?.toString() ?? "")
                  .font(.caption)
              }
            }
            .foregroundStyle(colorScheme == .dark ? .white : .black)
          } else {
            Text(viewModel.articles[index].title)
          }
        }
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}
