import Foundation
import Combine
import RegexBuilder
import SwiftTUI

class Day13ViewModel: DayViewModel {
  let title = Day.thirteen.rawValue

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

struct ClawMachine: DisplayableData {
  let buttonAMove: GridPosition
  let buttonBMove: GridPosition
  var prizeLocation: GridPosition

  var displayData: [AttributedString] {
    [
      AttributedString("--- Machine ---"),
      AttributedString("Button A: X+\(buttonAMove.row), Y+\(buttonAMove.column)"),
      AttributedString("Button B: X+\(buttonBMove.row), Y+\(buttonBMove.column)"),
      AttributedString("Prize location: \(prizeLocation)")
    ]
  }
}

struct Solution: DisplayableData {
  let aPresses: Int
  let bPresses: Int

  var displayData: [AttributedString] {
    [AttributedString("A: \(aPresses), B: \(bPresses)")]
  }
}

extension Day13ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day13.example
        case .puzzle: Inputs.Day13.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case findSolutions
    case computeTotalCost
    case addPrizeOffsets

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .findSolutions: "Find solutions"
        case .computeTotalCost: "Compute total cost"
        case .addPrizeOffsets: "Add prize offsets"
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

extension Day13ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findSolutions, computation: findSolutions)
        .dynamicNode(id: .computeTotalCost, computation: computeTotalCost)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .addPrizeOffsets, computation: addPrizeOffsets)
        .dynamicNode(id: .findSolutions, computation: findSolutions)
        .dynamicNode(id: .computeTotalCost, computation: computeTotalCost)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> [ClawMachine] {
    var machines = [ClawMachine]()

    let buttonAX = Reference<Int>()
    let buttonAY = Reference<Int>()

    let buttonBX = Reference<Int>()
    let buttonBY = Reference<Int>()

    let prizeX = Reference<Int>()
    let prizeY = Reference<Int>()

    let machinePattern = Regex {
      ZeroOrMore(.newlineSequence)
      
      "Button A: X+"
      Capture(as: buttonAX) {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ", Y+"
      Capture(as: buttonAY) {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      
      One(.newlineSequence)

      "Button B: X+"
      Capture(as: buttonBX) {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ", Y+"
      Capture(as: buttonBY) {
        OneOrMore(.digit)
      } transform: { Int($0)! }

      One(.newlineSequence)

      "Prize: X="
      Capture(as: prizeX) {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ", Y="
      Capture(as: prizeY) {
        OneOrMore(.digit)
      } transform: { Int($0)! }
    }

    let matches = input.matches(of: machinePattern)
    for match in matches {
      machines.append(
        ClawMachine(
          buttonAMove: GridPosition(row: match[buttonAY], column: match[buttonAX]), 
          buttonBMove: GridPosition(row: match[buttonBY], column: match[buttonBX]), 
          prizeLocation: GridPosition(row: match[prizeY], column: match[prizeX])
        )
      )
    }

    return machines
  }

  private static func findSolutions(_ input: [ClawMachine]) -> [Solution] {
    input.compactMap {
      let x1y = ($0.buttonAMove.column * $0.prizeLocation.row)
      let xy1 = ($0.prizeLocation.column * $0.buttonAMove.row)
      let x1y2 = ($0.buttonAMove.column * $0.buttonBMove.row)
      let x2y1 = ($0.buttonBMove.column * $0.buttonAMove.row)
      let b = (x1y - xy1) / (x1y2 - x2y1)

      let bx2 = b * $0.buttonBMove.column

      let a = ($0.prizeLocation.column - bx2) / $0.buttonAMove.column

      // guard a <= 100, b <= 100 else { return nil }

      let x = a * $0.buttonAMove.column + b * $0.buttonBMove.column
      guard x == $0.prizeLocation.column else { return nil }

      let y = a * $0.buttonAMove.row + b * $0.buttonBMove.row
      guard y == $0.prizeLocation.row else { return nil }

      return Solution(aPresses: a, bPresses: b)
    }
  }

  private static func computeTotalCost(_ input: [Solution]) -> Int {
    input.map {
      3 * $0.aPresses + $0.bPresses
    }
    .reduce(0, +)
  }

  private static func addPrizeOffsets(_ input: [ClawMachine]) -> [ClawMachine] {
    var machines = input

    for i in 0..<machines.count {
      machines[i].prizeLocation += GridPosition(row: 10000000000000, column: 10000000000000)
    }

    return machines
  }
}
