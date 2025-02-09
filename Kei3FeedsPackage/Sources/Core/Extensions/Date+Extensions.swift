import Foundation

extension Date {
  public func toString(format: String = "yyyy/MM/dd HH:mm") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}
