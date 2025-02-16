//
//  RSSNewpaper.swift
//  Kei3FeedsPackage
//
//  Created by Kei on 2025/02/17.
//

import Foundation

public struct RSSNewspaper: Identifiable, Sendable, Hashable {
  public let id = UUID()
  public let title: String
  public let link: URL?
  public let pubDate: Date?
  public let thumbnailImageURL: URL?
  public let iconImageURL: URL?

  public init(title: String, link: URL?, pubDate: Date?, thumbnailImageURL: URL?, iconImageURL: URL?) {
    self.title = title
    self.link = link
    self.pubDate = pubDate
    self.thumbnailImageURL = thumbnailImageURL
    self.iconImageURL = iconImageURL
  }
}
