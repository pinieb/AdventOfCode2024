import SwiftTUI

struct StepButton<ID>: View {
  private let id: ID
  private let stepNumber: Int
  private let title: String
  private var state: StepState
  private let action: (ID) -> Void

  init(
    id: ID,
    stepNumber: Int,
    title: String, 
    state: StepState, 
    action: @escaping (ID) -> Void
  ) {
    self.id = id
    self.stepNumber = stepNumber
    self.title = title
    self.state = state
    self.action = action
  }

  var body: some View {
    Button("\(checkboxText) \(stepNumber). \(title)") {
      action(id)
    }
    .foregroundColor(state == .enabled ? Color.green : Color.gray)
    .underline(state != .disabled)
  }

  private var checkboxText: String {
    switch state {
      case .disabled, .enabled: 
        return "[ ]"
      case .complete: 
        return "[X]"
    }
  }
}
