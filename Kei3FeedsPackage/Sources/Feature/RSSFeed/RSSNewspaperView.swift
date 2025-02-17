import Core
import Foundation
import SwiftUI
import Kingfisher

public struct RSSNewspaperView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss
  let newspapers: [RSSNewspaper]
  let leftNewspapers: [RSSNewspaper]
  let rightNewspapers: [RSSNewspaper]

  public init(newspapers: [RSSNewspaper]) {
    self.newspapers = newspapers
    let index = (newspapers.count + 1) / 2
    self.leftNewspapers = Array(newspapers.prefix(index))
    self.rightNewspapers = Array(newspapers.suffix(newspapers.count - index))
  }

  public var body: some View {
    ZStack {
      Image("newspaper-background-2")
        .resizable()
        .ignoresSafeArea()
      ScrollView {
        HStack {
          VStack(spacing: 8) {
            ForEach(leftNewspapers) { news in
              RSSNewspaperItemView(news)
            }
            Spacer()
          }

          VStack(spacing: 8) {
            ForEach(rightNewspapers) { news in
              RSSNewspaperItemView(news)
            }
            Spacer()
          }
        }
        .padding(.horizontal, 8)
      }
      
      VStack {
        Spacer()
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(.white)
            .padding(8)
        }
        .frame(width: 56, height: 56)
        .background(.indigo)
        .clipShape(.rect(cornerRadius: 28))
      }
    }
  }
}

public struct RSSNewspaperItemView: View {
  @Environment(\.colorScheme) var colorScheme
  let news: RSSNewspaper

  public init(_ news: RSSNewspaper) {
    self.news = news
  }

  public var body: some View {
    if let link = news.link {
      Link(destination: link) {
        ZStack {
          VStack {
            KFImage(news.thumbnailImageURL)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: UIScreen.main.bounds.width / 2 - 8) // 2列の幅に合わせる
              .clipShape(.rect(
                topLeadingRadius: 8,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 8
              ))
            HStack {
              Text(news.title)
                .font(.caption).bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
              Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            .padding(.top, 0)
            .background(.black.opacity(0.8))
          }
        }
        .background(.black.opacity(0.8))
      }
      .foregroundStyle(colorScheme == .dark ? .white : .black)
      .clipShape(.rect(
        topLeadingRadius: 8,
        bottomLeadingRadius: 8,
        bottomTrailingRadius: 0,
        topTrailingRadius: 8
      ))
      .padding(.vertical, 4)
    } else {
      Text("none")
    }
  }
}
