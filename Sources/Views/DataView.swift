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
    ScrollView {
      VStack(alignment: .leading) {
        ForEach(lines, id: \.self) { line in 
          Button(action: {}) {
            Text(line)
          }
        }
      }
      .frame(width: 200)
      .background(.black)
      .foregroundColor(.gray)
    }
  }
}
