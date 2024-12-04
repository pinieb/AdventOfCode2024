import Foundation
import SwiftTUI

struct WrappingText: View {
  @State var hasAppeared = false

  let text: AttributedString
  let width: Extended

  var body: some View {
    VStack {
      if !hasAppeared {
        Text(text)
      } else {
        ForEach(lines, id: \.self) { line in
          Button(action: {}) {
            Text(line)
          }
        }
      }
    }
    .onAppear { hasAppeared = true }
  }

  var lines: [AttributedString] {
    let textLength = text.characters.count
    var lines = [AttributedString]()

    for offset in stride(from: 0, to: textLength, by: width.intValue) {
      let lineLength = min(width.intValue, textLength - offset)

      let startIndex = text.index(text.startIndex, offsetByCharacters: offset)
      let endIndex = text.index(startIndex, offsetByCharacters: lineLength)
      let line = text[startIndex..<endIndex]
      lines.append(AttributedString(line))
    }

    return lines
  }
}
