import Foundation
import SwiftTUI

struct DataView: View {
  private let lines: [AttributedString]

  init(line: AttributedString) {
    self.lines = [line]
  }

  init(line: String) {
    self.lines = [AttributedString(line)]
  }

  init(lines: AttributedString...) {
    self.lines = lines
  }

  init(lines: [AttributedString]) {
    self.lines = lines
  }

  init(lines: String...) {
    self.lines = lines.map(AttributedString.init)
  }

  init(lines: [String]) {
    self.lines = lines.map(AttributedString.init)
  }

  var body: some View {
    GeometryReader { size in
      ScrollView {
        VStack(alignment: .leading) {
          ForEach(lines, id: \.self) { line in 
            WrappingText(text: line, width: size.width)
          }
        }
        .background(.black)
        .foregroundColor(.gray)
      }
    }
  }
}
