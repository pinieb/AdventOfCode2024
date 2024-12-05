import SwiftTUI

struct NavBar: View {
  @Environment(\.dismiss) var dismiss

  private let title: String

  init(title: String) {
    self.title = title
  }

  var body: some View {
    HStack(alignment: .top) {
      Button("< Back") {
        dismiss()
      }

      Spacer()

      Text(title)
        .foregroundColor(.green)

      Spacer()
    }
    .border()
  }
}
