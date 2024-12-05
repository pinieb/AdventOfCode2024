extension NodeProtocol {
  var stepState: StepState {
    switch state {
      case .awaitingInput: .disabled
      case .readyToRun: .enabled
      case .completed: .complete
    }
  }
}
