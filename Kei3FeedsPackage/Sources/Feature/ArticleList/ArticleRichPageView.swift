import Core
import SwiftUI

public struct ArticleRichPageView: View {
  @Environment(\.colorScheme) var colorScheme
  let articles: [Article]

  public init(articles: [Article]) {
    self.articles = articles
  }

  public var body: some View {
    ZStack {
      List {
        ForEach(articles, id: \.link) { article in
          Text(article.imageURL ?? "")
        }
      }
    }
  }
}
