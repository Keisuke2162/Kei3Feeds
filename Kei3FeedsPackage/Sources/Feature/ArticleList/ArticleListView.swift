import Core
import SwiftUI

public struct ArticleListView: View {
  @Environment(\.colorScheme) var colorScheme
  let articles: [Article]

  public init(articles: [Article]) {
    self.articles = articles
  }

  public var body: some View {
    ZStack {
      Color.blue
        .ignoresSafeArea()
      List {
        ForEach(articles.indices, id: \.self) { index in
          Link(destination: URL(string: articles[index].link)!) {
            VStack(alignment: .leading, spacing: 8) {
              Text(articles[index].title)
                .font(.headline)
                .lineSpacing(4)
                .padding(.top, 4)
              HStack {
                Spacer()
                Text(articles[index].published ?? "")
                  .font(.caption)
              }
            }
          }
          .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
      }
    }
    .overlay {
      Text("Empty")
        .opacity(articles.isEmpty ? 1 : 0)
    }
  }
}
