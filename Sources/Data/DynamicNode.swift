import Foundation

class DynamicNode<Identifier: Hashable, Input, Output>: NodeProtocol, InputReceiving {
  let id: Identifier

  var nextNode: (any InputReceiving<Output>)?
  private(set) var state: NodeState<Input, Output> = .awaitingInput

  private(set) var output: PipelineData<Output> = .none

  private let computation: (Input) -> Output

  init(id: Identifier, computation: @escaping (Input) -> Output) {
    self.id = id
    self.computation = computation
  }

  func run() {
    guard case .readyToRun(let input) = state else { return }
    
    let value = computation(input)
    nextNode?.sendInput(value)

    output = .value(value)
    state = .completed(output: value)
  }

  func sendInput(_ input: Input) {
    state = .readyToRun(input: input)
  }
}

extension DynamicNode: DisplayableNodeProtocol where Output: DisplayableData {}
