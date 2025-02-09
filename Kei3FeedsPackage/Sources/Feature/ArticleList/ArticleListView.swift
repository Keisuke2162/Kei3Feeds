import Core
import SwiftUI

public struct ArticleListView: View {

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
                .font(.subheadline)
                .padding(.top, 4)
              HStack {
                Spacer()
                Text(articles[index].published ?? "")
                  .font(.caption)
              }
            }
          }
          .foregroundStyle(Color.black)
        }
      }
    }
    .overlay {
      Text("Empty")
        .opacity(articles.isEmpty ? 1 : 0)
    }
  }
}
