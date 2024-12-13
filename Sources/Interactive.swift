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
    .four,
    .five,
    .six,
    .seven,
    .eight,
    .nine,
    .ten,
    .eleven,
    .twelve
  ])

  @State var displayingDay: Day?

  var body: some View {
    contentView
      .dismissAction { self.displayingDay = nil }
  }

  @ViewBuilder
  private var contentView: some View {
    switch displayingDay {
      case .three: DayThreeView()
      case .four: DayView(viewModel: Day4ViewModel())
      case .five: DayView(viewModel: Day5ViewModel())
      case .six: DayView(viewModel: Day6ViewModel())
      case .seven: DayView(viewModel: Day7ViewModel())
      case .eight: DayView(viewModel: Day8ViewModel())
      case .nine: DayView(viewModel: Day9ViewModel())
      case .ten: DayView(viewModel: Day10ViewModel())
      case .eleven: DayView(viewModel: Day11ViewModel())
      case .twelve: DayView(viewModel: Day12ViewModel())
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
