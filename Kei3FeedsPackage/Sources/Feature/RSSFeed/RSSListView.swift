//
//  RSSListView.swift
//  Kei3FeedsPackage
//
//  Created by Kei on 2025/02/16.
//

import SwiftUI
import Core
import Domain
import SwiftData

@MainActor
public class RSSListViewModel: ObservableObject {
  let feedRepository: any FeedRepositoryProtocol
  @Published var rssList: [RSSFeedMetaData] = []
  @Published var sheetType: SheetType?
  // MEMO: onAppearを2回目移行実行させないためのフラグ。あんま使いたくない
  var isLoaded: Bool = false

  public init(feedRepository: any FeedRepositoryProtocol) {
    self.feedRepository = feedRepository
  }

  // 画面表示時にSwiftDataに保存した情報からRSS一覧を作成する
  public func onAppear(feeds: [FeedModel]) {
    fetchRSSMetadata(feeds)
  }

  // RSS一覧に追加
  public func onAddFeedModel(url: URL, rss: RSSFeedMetaData, context: ModelContext) {
    let feedModel = FeedModel(title: rss.title, url: url)
    rssList.append(rss)
    context.insert(feedModel)
  }

  // RSS一覧から削除
  public func onDeleteFeedModel(feed: FeedModel, rss: RSSFeedMetaData, context: ModelContext) {
    context.delete(feed)
    // TODO: titleの比較からurlの比較に修正したい
    rssList.removeAll { $0.title == rss.title }
  }

  public func onTapedSheetButton(type: SheetType) {
    sheetType = type
  }

  private func fetchRSSMetadata(_ feeds: [FeedModel]) {
    rssList.removeAll()
    let urls = feeds.map { $0.url }
    for url in urls {
      Task {
        do {
          let rss = try await feedRepository.fetchRSSMetadata(from: url)
          await MainActor.run {
            self.rssList.append(rss)
          }
        } catch {
        }
      }
    }
  }
}

public struct RSSListView: View {
  @Query private var feeds: [FeedModel]
  
  @Environment(\.modelContext) private var context
  @StateObject var viewModel: RSSListViewModel
  
  public init(viewModel: RSSListViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      ZStack {
        List {
          ForEach(viewModel.rssList, id: \.id) { rss in
            NavigationLink {
              Text("nav")
            } label: {
              VStack(alignment: .leading, spacing: 8) {
                Text(rss.title)
                  .font(.subheadline)
                  .padding(.top, 4)
                HStack {
                  Text(rss.lastUpdatedString)
                    .font(.caption)
                  Spacer()
                }
              }
            }
          }
        }
      }
    }
    .onAppear {
      viewModel.onAppear(feeds: feeds)
    }
  }
}
