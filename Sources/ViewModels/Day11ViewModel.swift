import Foundation
import Combine
import SwiftTUI


class Day11ViewModel: DayViewModel {
  let title = Day.eleven.rawValue

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

struct PebbleLine: DisplayableData {

  private(set) var stones: [Int]

  struct CacheKey: Hashable {
    let seed: Int
    let steps: Int
  }

  private(set) var cache = [CacheKey: Int]()

  init(stones: [Int]) {
    self.stones = stones
  }

  mutating func blink(count: Int = 1) {
    stones = stones.flatMap { runSteps(seed: $0, steps: count) }
  }

  private mutating func runSteps(seed: Int, steps: Int) -> [Int] {
    guard steps > 0 else {
      return [seed]
    }

    var output = [Int]()

    for newSeed in simulateStep(seed: seed) {
      output += runSteps(seed: newSeed, steps: steps - 1)
    }

    return output
  }

  mutating func stonesAfter(blinks: Int) -> Int {
    stones.map {
      countOutput(seed: $0, steps: blinks)
    }
    .reduce(0, +)
  }

  private mutating func countOutput(seed: Int, steps: Int) -> Int {
    let cacheKey = CacheKey(seed: seed, steps: steps)
    if let cached = cache[cacheKey] { return cached }

    guard steps > 0 else {
      cache[cacheKey] = 1
      return 1
    }

    var count = 0

    for newSeed in simulateStep(seed: seed) {
      count += countOutput(seed: newSeed, steps: steps - 1)
    }

    cache[cacheKey] = count
    return count
  }

  private func simulateStep(seed: Int) -> [Int] {
    if seed == 0 {
      return [1]
    }

    let string = String(seed)
    if string.count.isMultiple(of: 2) {
      return [
          Int(
            String(string.dropLast(string.count / 2))
          )!,
          Int(
            String(string.dropFirst(string.count / 2))
          )!
      ]
    }

    return [seed * 2024]
  }

  var displayData: [AttributedString] {
    [AttributedString("\(stones)")]
  }
}

extension Day11ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day11.example
        case .puzzle: Inputs.Day11.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case process25Blinks
    case process75Blinks

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .process25Blinks: "Process 25 blinks"
        case .process75Blinks: "Process 75 blinks"
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

extension Day11ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .process25Blinks, computation: process25Blinks)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .process75Blinks, computation: process75Blinks)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> PebbleLine {
    PebbleLine(stones: input.split(separator: " ").map { Int($0)! })
  }

  private static func process25Blinks(_ input: PebbleLine) -> Int {
    var pebbleLine = input

    pebbleLine.blink(count: 25)

    return pebbleLine.stones.count
  }

  private static func process75Blinks(_ input: PebbleLine) -> Int {
    var pebbleLine = input

    return pebbleLine.stonesAfter(blinks: 75)
  }
}
