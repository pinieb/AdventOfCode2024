import Foundation

protocol Runnable {
  func run()
}

enum PipelineData<Value> {
  case none
  case value(_ value: Value)
}

extension PipelineData: DisplayableData where Value: DisplayableData {
    var displayData: [AttributedString] {
      switch self {
        case .none: [AttributedString("This step has not run yet.")]
        case .value(let value): value.displayData
      } 
    }
}

protocol InputReceiving<Input> {
  associatedtype Input

  func sendInput(_ input: Input)
}

protocol OutputProviding<Output> {
  associatedtype Output

  var output: PipelineData<Output> { get }
}

enum NodeState<Input, Output> { 
  case awaitingInput
  case readyToRun(input: Input)
  case completed(output: Output)
}

protocol NodeProtocol<ID>: AnyObject, Identifiable, InputReceiving, OutputProviding, Runnable {
  // associatedtype Input
  // associatedtype Output

  var nextNode: (any InputReceiving<Output>)? { get set }

  var state: NodeState<Input, Output> { get }
}

protocol DisplayableNodeProtocol<ID>: NodeProtocol where Output: DisplayableData {}

extension DisplayableNodeProtocol {
  var displayableOutput: DisplayableData {
    output
  }

  var displayOutput: [AttributedString] {
    switch output {
      case .none: [AttributedString("This step has not run yet.")]
      case .value(let value): value.displayData
    } 
   }
}

protocol PipelineProtocol<NodeIdentifier> {
  associatedtype NodeIdentifier
  associatedtype NodeType

  var nodes: [NodeType] { get }

  func runNode(id: NodeIdentifier)
}

class Pipeline<NodeIdentifier: Hashable, NodeType: NodeProtocol<NodeIdentifier>>: PipelineProtocol {
    var nodes: [NodeType]

    init(nodes: [NodeType]) {
      self.nodes = nodes
    }

    convenience init(@PipelineBuilder<NodeIdentifier> builder: () -> [NodeType]) {
      self.init(nodes: builder())
    }

    func runNode(id: NodeIdentifier) {
      nodes.first { $0.id == id }?.run()
    }
}

class DisplayablePipeline<NodeIdentifier: Hashable>: PipelineProtocol {
  typealias NodeType = any DisplayableNodeProtocol<NodeIdentifier>
  
  var nodes: [NodeType]

  init(nodes: [NodeType]) {
    self.nodes = nodes
  }

  convenience init(@DisplayablePipelineBuilder2<NodeIdentifier> builder: () -> [NodeType]) {
    self.init(nodes: builder())
  }

  func runNode(id: NodeIdentifier) {
    nodes.first { $0.id == id }?.run()
  }
}
