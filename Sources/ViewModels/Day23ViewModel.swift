import Foundation
import Combine
import SwiftTUI


class Day23ViewModel: DayViewModel {
  let title = Day.twentyThree.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.example {
    didSet {
      resetState()
    }
  }

  @Published private(set) var selectedStep: StepID

  @Published private var pipelines: [Subproblem: DisplayablePipeline<StepID>]

  var steps: [Step<StepID>] {
    pipelines[selectedPart]?
      .nodes
      .enumerated()
      .map { (stepNumber, node) in
        Step(
          id: node.id, 
          number: stepNumber, 
          title: node.id.description, 
          state: node.stepState
        )
      } ?? []
  }

  var output: StepOutput {
    guard let currentNode = pipelines[selectedPart]?.nodes.first(where: { $0.id == selectedStep }) else {
      return .text("Nothing is here yet!")
    }

    return .data(currentNode.displayableOutput)
  }

  init() {
    let input = Input.example
    self.selectedInput = input
    self.pipelines = Self.makePipelines(input: input)
    self.selectedStep = .loadData
  }

  private func resetState() {
    self.pipelines = Self.makePipelines(input: selectedInput)
    self.selectedStep = .loadData
  }

  func runStep(id: StepID) {
    selectedStep = id

    guard 
      let currentStep = steps.first(where: { $0.id == id }),
      currentStep.state == .enabled
    else {
      return
    }

    pipelines[selectedPart]?.runNode(id: id)
  }
}

// MARK: - Data types

fileprivate struct NetworkGraph: DisplayableData {
  let computers: Set<String>

  private(set) var subnets: [Int: Set<Set<String>>]

  init(connections: [Set<String>]) {
    var computers = Set<String>()
    var subnets = [Int: Set<Set<String>>]()

    for connection in connections {
      subnets[connection.count, default: Set()].insert(connection)

      computers.formUnion(connection)
    }

    self.computers = computers
    self.subnets = subnets
  }

  var displayData: [AttributedString] {
    [AttributedString("Subnets: ")]
    + subnets.keys
      .sorted { $0 > $1 }
      .map { key in
        AttributedString("Size: \(key), count: \(subnets[key]?.count ?? 0)")
      }
  }

  mutating func growSubnets() {
    guard let maxSize = subnets.keys.max() else { return }

    for computer in computers  {
      let computerConnections = subnets[maxSize]?
        .filter { $0.contains(computer) }
        .reduce(into: Set<String>()) { result, next in
          result.formUnion(next)
        } ?? []

      for subnet in subnets[maxSize] ?? [] where !subnet.contains(computer) {
        if subnet.intersection(computerConnections) == subnet {
          subnets[maxSize + 1, default: Set()].insert(subnet.union([computer]))
        }
      }
    }
  }
}

extension Day23ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day23.example
        case .puzzle: Inputs.Day23.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case growSubnets
    case countSize3SubnetsWithTComputers
    case getPassword

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .growSubnets: "Grow subnets"
        case .countSize3SubnetsWithTComputers: "Count size 3 subnets with T computers"
        case .getPassword: "Get password"
      }
    }

    var isFirstStep: Bool {
      switch self {
        case .loadData: return true
        default: return false
      }
    }
  }
}

// MARK: - Pipelines

extension Day23ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .growSubnets, computation: growSubnets)
        .dynamicNode(id: .countSize3SubnetsWithTComputers, computation: countSize3SubnetsWithTComputers)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .repeatableNode(id: .growSubnets, computation: growSubnets)
        .dynamicNode(id: .getPassword, computation: getPassword)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> NetworkGraph {
    let connections = input
      .lines
      .map { line in 
        Set(line.split(separator: "-").map { String($0)} )
      }

    return NetworkGraph(connections: connections)
  }

  private static func growSubnets(_ input: NetworkGraph) -> NetworkGraph {
    var graph = input

    graph.growSubnets()

    return graph
  }

  private static func countSize3SubnetsWithTComputers(_ input: NetworkGraph) -> Int {
    let tComputers = input.computers.filter { $0.hasPrefix("t") }

    return input.subnets[3]?
      .count { net in 
        net.intersection(tComputers).count > 0
      } ?? 0
  }

  private static func getPassword(_ input: NetworkGraph) -> String {
    guard let maxNetworkSize = input.subnets.keys.max() else {
      return "None"
    }

    guard let computers = input.subnets[maxNetworkSize]?.first else { return "None" }

    return Array(computers.sorted()).joined(separator: ",")
  }
}
