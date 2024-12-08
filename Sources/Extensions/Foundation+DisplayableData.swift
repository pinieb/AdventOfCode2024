import Foundation

extension String: DisplayableData {
  var displayData: [AttributedString] {
    self.split(whereSeparator: \.isNewline)
      .map { AttributedString($0) }
  }
}

extension Int: DisplayableData {
  var displayData: [AttributedString] {
    "\(self)".displayData
  }
}

extension Array: DisplayableData where Element: DisplayableData {
  var displayData: [AttributedString] {
    self
      .map { $0.displayData }
      .flatMap { $0 }
  }
}
