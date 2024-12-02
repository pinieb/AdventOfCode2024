protocol VerbosePrintable {
  var options: SharedOptions { get }
}

extension VerbosePrintable {
  // MARK: - Printing

  func verbosePrint<T: CustomStringConvertible>(_ item: T) {
    guard options.verbose else { return }

    print(item)
  }

  func verbosePrint<T: CustomStringConvertible>(_ list: [T], onNewLine: Bool = false) {
    guard options.verbose else { return }

    guard onNewLine else {
      print(list)
      return
    }

    for item in list {
      print(item)
    }
  }

  func verbosePrint(_ list: [[Int]]) {
    guard options.verbose else { return }

    for item in list {
      verbosePrint(item)
    }
  }
}
