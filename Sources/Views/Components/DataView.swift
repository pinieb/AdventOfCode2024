import Foundation
import SwiftTUI

struct DataView: View {
  private let data: any DisplayableData

  init(data: any DisplayableData) {
    self.data = data
  }

  var body: some View {
    GeometryReader { size in
      ScrollView {
        VStack(alignment: .leading) {
          ForEach(data.displayData, id: \.self) { line in 
            WrappingText(text: line, width: size.width)
          }
        }
      }
    }
  }
}
