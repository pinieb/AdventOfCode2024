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
