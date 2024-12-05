import SwiftTUI

protocol SelectionItem: Identifiable {
  var label: String { get }
}

struct SegmentedButton<Item: SelectionItem>: View {
  let options: [Item]
  @Binding var selection: Item

  var body: some View {
    HStack(alignment: .center) {
      ForEach(Array(options.enumerated()), id: \.element.id) { index, option in 
        Button(option.label) { selection = option }
          .bold(selection.id == option.id)
          .underline(selection.id == option.id)
          .background(selection.id == option.id ? Color.gray : Color.default)

          if index < options.count - 1 {
            Divider()
          }
      }
    }
    .padding(.horizontal, 1)
    .border()
  }
}
