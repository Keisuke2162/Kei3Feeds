import Core
import Foundation

class RSSArticleParser: NSObject, XMLParserDelegate {
  private var articles: [RSSArticle] = []
  private var currentElement = ""
  private var currentTitle: String?
  private var currentLinkString = ""
  private var currentLink: URL?
  private var currentPubDate: Date?
  private var dateFormatter: DateFormatter

  override init() {
    self.dateFormatter = DateFormatter()
    self.dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
  }

  // パース開始時
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if currentElement == "item" || currentElement == "entry" {
      currentTitle = nil
      currentLink = nil
      currentPubDate = nil
    }
  }

  // XMLの中身を取得
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch currentElement {
    case "title":
      currentTitle = (currentTitle ?? "") + trimmedString
    case "link":
      if !trimmedString.isEmpty {
        currentLink = URL(string: trimmedString)
      }
    case "pubDate":
      if let date = dateFormatter.date(from: trimmedString) {
        currentPubDate = date
      }
    default:
      break
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "item" || elementName == "entry" {
      if let title = currentTitle {
        let article = RSSArticle(title: title, link: currentLink, pubDate: currentPubDate)
        articles.append(article)
      }
    }
  }

  func parse(data: Data) -> [RSSArticle] {
    let parser = XMLParser(data: data)
    parser.delegate = self
    return parser.parse() ? articles : []
  }
}
