import SwiftTUI

protocol SelectionItem: Identifiable {
  var label: String { get }
}

struct SegmentedButton<Item: SelectionItem>: View {
  let options: [Item]
  @Binding var selection: Item

  var body: some View {
    HStack {
      ForEach(options) { option in 
        Button(option.label) { selection = option }
          .bold(selection.id == option.id)
          .underline(selection.id == option.id)
          .background(selection.id == option.id ? Color.gray : Color.default)
      }
    }
    .border()
  }
}
