import Foundation
import Core

class RSSMetaDataParser: NSObject, XMLParserDelegate {
  private var currentElement = ""
  private var title: String?
  private var lastUpdated: Date?
  private var dateFormatter: DateFormatter
  private var isChannel: Bool = false
  
  override init() {
    self.dateFormatter = DateFormatter()
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == "channel" {
      isChannel = true
    }
    if elementName == "item" || elementName == "entry" {
      isChannel = false
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let trimmingString = string.trimmingCharacters(in: .whitespacesAndNewlines)
    guard isChannel else { return }

    if currentElement == "title", trimmingString != title {
      title = (title ?? "") + trimmingString
    } else if currentElement == "lastBuildDate" || currentElement == "updated" || currentElement == "pubDate" {
      self.dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
      if let date = dateFormatter.date(from: trimmingString) {
        lastUpdated = date
      }
    } else if currentElement == "dc:date" {
      self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      if let date = dateFormatter.date(from: trimmingString) {
        lastUpdated = date
      }
    }
  }
  
  func parse(data: Data, url: URL) -> RSSFeedMetaData? {
    let parser = XMLParser(data: data)
    parser.delegate = self
    return parser.parse() ? RSSFeedMetaData(title: title ?? "", lastUpdated: lastUpdated, url: url) : nil
  }
}
