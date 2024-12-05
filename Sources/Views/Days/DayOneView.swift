import SwiftTUI

struct DayOneView: View {
  var body: some View {
    VStack(alignment: .leading) {
      NavBar(title: Day.one.rawValue)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
