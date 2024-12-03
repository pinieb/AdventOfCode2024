enum Subproblem: Int, CaseIterable, Hashable, Equatable {
  case partOne
  case partTwo
}

extension Subproblem: Identifiable {
  var id: Int { self.rawValue }
}

extension Subproblem: SelectionItem {
  var label: String {
    switch self {
      case .partOne: "Part one"
      case .partTwo: "Part two"
    }
  }
}
