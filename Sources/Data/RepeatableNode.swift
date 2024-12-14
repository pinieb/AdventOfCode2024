import Foundation

class RepeatableNode<Identifier: Hashable, Input>: NodeProtocol, InputReceiving {
  let id: Identifier

  var nextNode: (any InputReceiving<Input>)?
  private(set) var state: NodeState<Input, Input> = .awaitingInput

  private(set) var output: PipelineData<Input> = .none

  private let computation: (Input) -> Output

  init(id: Identifier, computation: @escaping (Input) -> Input) {
    self.id = id
    self.computation = computation
  }

  func run() {
    guard case .readyToRun(let input) = state else { return }
    
    let value = computation(input)
    nextNode?.sendInput(value)

    output = .value(value)
    state = .readyToRun(input: value)
  }

  func sendInput(_ input: Input) {
    state = .readyToRun(input: input)
  }
}

extension RepeatableNode: DisplayableNodeProtocol where Output: DisplayableData {}
