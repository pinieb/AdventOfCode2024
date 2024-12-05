import Foundation
import ArgumentParser
import SwiftTUI

struct Interactive: ParsableCommand {
  mutating func run() {
    Application(rootView: RootView()).start()
  }
}

struct RootView: View {
  private let enabledDays = Set<Day>([
    .three,
    .four
  ])

  @State var displayingDay: Day?

  var body: some View {
    contentView
      .dismissAction { self.displayingDay = nil }
  }

  @ViewBuilder
  private var contentView: some View {
    switch displayingDay {
      case .one: DayOneView()
      case .three: DayThreeView()
      case .four: Day4()
      default: menuView
    }
  }

  @ViewBuilder
  private var menuView: some View {
    ScrollView {
      ForEach(Day.allCases, id: \.self) { day in
        makeEntry(for: day)
      }
    }
  }

  @ViewBuilder
  private func makeEntry(for day: Day) -> some View {
    Button(day.rawValue) {
      self.displayingDay = day
    }
    .foregroundColor(enabledDays.contains(day) ? Color.green : Color.gray)
  }
}
