import Foundation

enum StepState: Equatable {
  case disabled
  case enabled
  case complete
}

struct Step<ID: Hashable & Equatable>: Identifiable, Equatable {
  let id: ID
  let number: Int
  let title: String
  var state: StepState

  init(
    id: ID,
    number: Int,
    title: String,
    state: StepState = .disabled
  ) {
    self.id = id
    self.number = number
    self.title = title
    self.state = state
  }
}
