import Foundation
import Collections
import Combine
import SwiftTUI

class Day22ViewModel: DayViewModel {
  let title = Day.twentyTwo.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.example1 {
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
    let input = Input.example1
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

fileprivate struct SecretGenerator: DisplayableData {
  private(set) var secrets: [Int]

  init(secrets: [Int]) {
    self.secrets = secrets
  }

  var displayData: [AttributedString] {
    secrets.displayData
  }

  mutating func generateSecrets(after steps: Int = 1) {
    for index in secrets.indices {
      for _ in 0..<steps {
        secrets[index] = step3(secret: step2(secret: step1(secret: secrets[index])))
      }
    }
  }

  private func step1(secret: Int) -> Int {
    prune(mix(secret, secret << 6))
  }

  private func step2(secret: Int) -> Int {
    prune(mix(secret, secret >> 5))
  }

  private func step3(secret: Int) -> Int {
    prune(mix(secret, secret << 11))
  }

  private func mix(_ x: Int, _ y: Int) -> Int {
    x ^ y
  }

  private func prune(_ x: Int) -> Int {
    let modulo = (1 << 24) - 1
    
    return x & modulo
  }
}

extension Day22ViewModel {
  enum Input: String, InputProtocol {
    case example1 = "Example 1"
    case example2 = "Example 2"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example1: Inputs.Day22.example1
        case .example2: Inputs.Day22.example2
        case .puzzle: Inputs.Day22.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case run2000Steps
    case sumSecrets
    case findMaxProfit

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .run2000Steps: "Run 2,000 steps"
        case .sumSecrets: "Sum secrets"
        case .findMaxProfit: "Find max profit"
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

extension Day22ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .run2000Steps, computation: run2000Steps)
        .dynamicNode(id: .sumSecrets, computation: sumSecrets)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findMaxProfit, computation: findMaxProfit)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> SecretGenerator {
    let seeds = input.lines.map { Int($0)! }

    return SecretGenerator(secrets: seeds)
  }

  private static func run2000Steps(_ input: SecretGenerator) -> SecretGenerator {
    var data = input

    data.generateSecrets(after: 2000)

    return data
  }

  private static func findMaxProfit(_ input: SecretGenerator) -> Int {
    var generators = input.secrets.map { SecretGenerator(secrets: [$0]) }
    var cumulativeProfits = [[Int]: Int]()

    for index in generators.indices {
      var history = [generators[index].secrets.first! % 10]
      var profits = [[Int]: Int]()

      for _ in 0..<2000 {
        generators[index].generateSecrets()
        history.append(generators[index].secrets.first! % 10)
      }

      let diffs = history
        .adjacentPairs()
        .map { $1 - $0 }
        
      let groups = diffs[3...]
        .indices
        .map { 
          Array(diffs[($0 - 3)...$0])
        }

        zip(groups, history[4...])
          .forEach { (group, price) in
            guard profits[group] == nil else { return }

            profits[group] = price
          }
      
      for (key, value) in profits {
        cumulativeProfits[key, default: 0] += value
      }
    }

    return cumulativeProfits.values.max() ?? 0
  }

  private static func sumSecrets(_ input: SecretGenerator) -> Int {
    input.secrets.reduce(0, +)
  }

  private static func findLoop(_ input: SecretGenerator) -> [Int] {
    var seen = OrderedSet<Int>()

    var data = input

    while true {
      guard !seen.contains(data.secrets.first!) else { break }
      seen.append(data.secrets.first!)

      data.generateSecrets()
    }

    return Array(seen)
  }
}
