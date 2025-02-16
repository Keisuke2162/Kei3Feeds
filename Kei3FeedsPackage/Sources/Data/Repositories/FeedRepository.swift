import Core
import Foundation
import Domain
import FeedKit
import SwiftSoup

public final class FeedRepository: FeedRepositoryProtocol {
  public init() {
  }

  public func fetchRSSMetadata(from url: URL) async throws -> RSSFeedMetaData {
    let (data, _) = try await URLSession.shared.data(from: url)
    if let metadata = RSSMetaDataParser().parse(data: data) {
      return metadata
    } else {
      throw FeedError.unknown
    }
  }

  public func fetchFeed(url: URL) async throws -> CustomFeed {
    let feedParser = FeedParser(URL: url)

    return try await withCheckedThrowingContinuation { continuation in
      feedParser.parseAsync { [weak self] result in
        switch result {
        case .success(let feed):
          guard let self else { return continuation.resume(throwing: FeedError.unknown) }
          continuation.resume(returning: self.transformFeed(url, feed))
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  public func fetchOGP(articles: [Article]) async throws -> [Article] {
    var newArticles: [Article] = []
    for article in articles {
      var newArticle = article
      let ogpImageURL = await fetchOGImageAsync(from: article.link)
      newArticle.imageURL = ogpImageURL
      newArticles.append(newArticle)
    }
    return newArticles
  }

  private func transformFeed(_ feedURL: URL, _ feed: Feed) -> CustomFeed {
    switch feed {
    case .atom(let atomFeed):
      return transformAtomFeed(feedURL, atomFeed)
    case .rss(let rSSFeed):
      return transformRssFeed(feedURL, rSSFeed)
    case .json(let jsonFeed):
      return transformJsonFeed(feedURL, jsonFeed)
    }
  }

  // MARK: Atom
  // TODO: UUID().uuidStringはSwiftDataのidを使うように修正
  private func transformAtomFeed(_ feedURL: URL, _ feed: AtomFeed) -> CustomFeed {
    let articles = feed.entries?.compactMap { entry -> Article? in
      guard let title = entry.title,
            let link = entry.links?.first?.attributes?.href else {
        return nil
      }
      return Article(
        title: title,
        link: link,
        publishedAt: entry.published ?? entry.updated,
        imageURL: entry.content?.attributes?.src,
        description: entry.summary?.value ?? ""
      )
    }
    return CustomFeed(
//      id: UUID().uuidString,
      title: feed.title ?? "",
      url: feedURL.absoluteString,
      lastUpdated: feed.updated,
      imageURL: feed.logo,
      articles: articles ?? []
    )
  }

  // MARK: RSS
  private func transformRssFeed(_ feedURL: URL, _ feed: RSSFeed) -> CustomFeed {
    let articles = feed.items?.compactMap { item -> Article? in
      guard let title = item.title, let link = item.link else { return nil }
      return Article(
        title: title,
        link: link,
        publishedAt: item.pubDate,
        imageURL: item.enclosure?.attributes?.url,
        description: item.description ?? ""
      )
    }
    return CustomFeed(
//      id: UUID().uuidString,
      title: feed.title ?? "",
      url: feedURL.absoluteString,
      lastUpdated: feed.pubDate,
      imageURL: feed.image?.url,
      articles: articles ?? []
    )
  }

  // MARK: JSON
  private func transformJsonFeed(_ feedURL: URL, _ feed: JSONFeed) -> CustomFeed {
    let articles = feed.items?.compactMap { item -> Article? in
      guard let title = item.title, let link = item.url else { return nil }
      return Article(
        title: title,
        link: link,
        publishedAt: item.datePublished,
        imageURL: item.image,
        description: item.contentText ?? ""
      )
    }

    return CustomFeed(
//      id: UUID().uuidString,
      title: feed.title ?? "",
      url: feedURL.absoluteString,
      lastUpdated: articles?.first?.publishedAt,  // date情報ないかも
      imageURL: feed.icon,
      articles: articles ?? []
    )
  }

  private func fetchOGImageAsync(from url: String) async -> String? {
    guard let articleURL = URL(string: url) else { return nil }
    do {
      let (data, _) = try await URLSession.shared.data(from: articleURL)
      let html = String(data: data, encoding: .utf8)
      let doc = try SwiftSoup.parse(html ?? "")
      return try doc.select("meta[property=og:image]").first()?.attr("content")
    } catch {
      print("Failed fetch OGP: \(error)")
      return nil
    }
  }
}
