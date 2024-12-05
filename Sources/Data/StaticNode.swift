class StaticNode<Identifier: Hashable, Value>: NodeProtocol {
  typealias Input = None

  let id: Identifier
  var state: NodeState<None, Value> { .completed(output: value) }
  var output: PipelineData<Value> { .value(value) }

  var nextNode: (any InputReceiving<Value>)? {
    didSet {
      nextNode?.sendInput(value)
    }
  }

  private let value: Value

  init(id: Identifier, value: Value) {
    self.id = id
    self.value = value
  }

  func run() {
    nextNode?.sendInput(value)
  }

  func sendInput(_ input: None) {}
}

extension StaticNode: DisplayableNodeProtocol where Value: DisplayableData {}
