import Algorithms
import Foundation
import Combine
import SwiftTUI

class Day21ViewModel: DayViewModel {
  let title = Day.twentyOne.rawValue

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

// MARK: - Problem data

fileprivate enum NumericKey: String, CustomStringConvertible, Hashable, CaseIterable {
  case zero = "0"
  case one = "1"
  case two = "2"
  case three = "3"
  case four = "4"
  case five = "5"
  case six = "6"
  case seven = "7"
  case eight = "8"
  case nine = "9"
  case a = "A"

  var description: String { self.rawValue }

  var position: GridPosition {
    switch self {
      case .seven: GridPosition(row: 0, column: 0)
      case .eight: GridPosition(row: 0, column: 1)
      case .nine: GridPosition(row: 0, column: 2)
      case .four: GridPosition(row: 1, column: 0)
      case .five: GridPosition(row: 1, column: 1)
      case .six: GridPosition(row: 1, column: 2)
      case .one: GridPosition(row: 2, column: 0)
      case .two: GridPosition(row: 2, column: 1)
      case .three: GridPosition(row: 2, column: 2)
      case .zero: GridPosition(row: 3, column: 1)
      case .a: GridPosition(row: 3, column: 2)
    }
  }
}

fileprivate enum DirectionalKey: String, CustomStringConvertible, Hashable, CaseIterable {
  case left = "<"
  case right = ">"
  case up = "^"
  case down = "v"
  case a = "A"

  var description: String { self.rawValue }

  var position: GridPosition {
    switch self {
      case .up: GridPosition(row: 0, column: 1)
      case .a: GridPosition(row: 0, column: 2)
      case .left: GridPosition(row: 1, column: 0)
      case .down: GridPosition(row: 1, column: 1)
      case .right: GridPosition(row: 1, column: 2)
    }
  }

  var vector: GridPosition {
    switch self {
      case .up: GridPosition(row: -1, column: 0)
      case .down: GridPosition(row: 1, column: 0)
      case .left: GridPosition(row: 0, column: -1)
      case .right: GridPosition(row: 0, column: 1)
      case .a: GridPosition(row: 0, column: 0)
    }
  }
}

fileprivate struct Instruction: CustomStringConvertible {
  let moves: [Direction: Int]
  
  init(moves: [Direction: Int]) {
    self.moves = moves
  }

  var steps: Int { 
    moves.values.reduce(1, +)
  }

  var description: String {
    var output = ""

    if let east = moves[.east] {
      output += [Character](repeating: ">", count: east)
    }

    if let west = moves[.west] {
      output += [Character](repeating: "<", count: west)
    }

    if let north = moves[.north] {
      output += [Character](repeating: "^", count: north)
    }

    if let south = moves[.south] {
      output += [Character](repeating: "v", count: south)
    }

    output += "A"

    return output
  }
}

fileprivate enum KeypadType: Equatable, Hashable {
  case numeric
  case directional
}

fileprivate struct ProblemData: DisplayableData {
  let codes: [[NumericKey]]

  init(codes: [[NumericKey]]) {
    self.codes = codes
  }

  var displayData: [AttributedString] {
    [AttributedString("Codes:")]
    + codes.map { 
      AttributedString("\($0)")
    }
  }

  private struct CacheKey: Hashable, Equatable {
    let start: String
    let end: String
    let directionalRobots: Int
    let keypad: KeypadType
  }
  private var cache = [CacheKey: Int]()

  mutating func getLowestCost(
    from start: String,
    to end: String,
    directionalRobots: Int,
    keypad: KeypadType
  ) -> Int {
    let cacheKey = CacheKey(
        start: start, 
        end: end, 
        directionalRobots: directionalRobots, 
        keypad: keypad
      )

    if let cached = cache[cacheKey] {
      return cached
    }

    let startPosition: GridPosition
    let endPosition: GridPosition
    switch keypad {
      case .numeric: 
        startPosition = (NumericKey(rawValue: start) ?? .a).position
        endPosition = (NumericKey(rawValue: end) ?? .a).position
      case .directional:
        startPosition = (DirectionalKey(rawValue: start) ?? .a).position
        endPosition = (DirectionalKey(rawValue: end) ?? .a).position
    }

    let validKeys = Self.validKeyPresses(
      from: startPosition, 
      to: endPosition, 
      keypad: keypad
    )

    guard directionalRobots > 0 else {
      let result = validKeys
        .map { $0.count }
        .min() ?? Int.max

      cache[cacheKey] = result
      return result
    }

    let result = validKeys
      .map { keys in
        ([.a] + keys).adjacentPairs()
          .map { 
            getLowestCost(
              from: $0.rawValue, 
              to: $1.rawValue, 
              directionalRobots: directionalRobots - 1,
              keypad: .directional
            )
          }
          .reduce(0, +)
      }
      .min() ?? Int.max

      cache[cacheKey] = result
      return result
  }

  mutating func getCost(keys: [NumericKey], directionalRobots: Int) -> Int {
    ([.a] + keys).adjacentPairs()
      .map { 
        getLowestCost(
          from: $0.rawValue, 
          to: $1.rawValue, 
          directionalRobots: directionalRobots, 
          keypad: .numeric
        )
      }.reduce(0, +)
  }

  private static func directionalKeys(
    from vector: GridPosition
  ) -> [DirectionalKey] {
    var keys = [DirectionalKey]()
    
    if vector.column < 0 {
      keys += [DirectionalKey](repeating: .left, count: abs(vector.column))
    } else if vector.column > 0 {
      keys += [DirectionalKey](repeating: .right, count: abs(vector.column))
    }

    if vector.row < 0 {
      keys += [DirectionalKey](repeating: .up, count: abs(vector.row))
    } else if vector.row > 0 {
      keys += [DirectionalKey](repeating: .down, count: abs(vector.row))
    }

    return keys
  }

  private static func validKeyPresses(
    from start: GridPosition, 
    to end: GridPosition, 
    keypad: KeypadType
  ) -> [[DirectionalKey]] {
    let vector = end - start
    
    return directionalKeys(from: vector)
      .uniquePermutations()
      .filter { isPathValid(from: start, moves: $0, keypad: keypad) }
      .map { $0 + [.a] }
  }

  private static func isPathValid(
    from start: GridPosition,
    moves: [DirectionalKey],
    keypad: KeypadType
  ) -> Bool {
    var cell = start

    guard isValid(position: cell, keypad: keypad) else { return false }

    for move in moves {
      cell += move.vector
      guard isValid(position: cell, keypad: keypad) else { return false }
    }

    return true
  }

  private static func isValid(position: GridPosition, keypad: KeypadType) -> Bool {
    switch keypad {
      case .numeric: position != GridPosition(row: 3, column: 0)
      case .directional: position != GridPosition(row: 0, column: 0)
    }
  }

}

extension Day21ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day21.example
        case .puzzle: Inputs.Day21.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case computeComplexities2Robots
    case computeComplexities25Robots
    case sumComplexities

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .computeComplexities2Robots: "Compute complexities w/ 2 directional bots"
        case .computeComplexities25Robots: "Compute complexities w/ 25 directional bots"
        case .sumComplexities: "Sum complexities"
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

extension Day21ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .computeComplexities2Robots, computation: computeComplexities2Robots)
        .dynamicNode(id: .sumComplexities, computation: sumComplexities)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .computeComplexities25Robots, computation: computeComplexities25Robots)
        .dynamicNode(id: .sumComplexities, computation: sumComplexities)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> ProblemData {
    let codes = input.lines
      .map {
        Array($0)
          .compactMap { NumericKey(rawValue: String($0)) }
      }

    return ProblemData(codes: codes)
  }

  private static func computeComplexities2Robots(_ input: ProblemData) -> [Int] {
    computeComplexities(input, directionalRobots: 2)
  }

  private static func computeComplexities25Robots(_ input: ProblemData) -> [Int] {
    computeComplexities(input, directionalRobots: 25)
  }

  private static func computeComplexities(_ input: ProblemData, directionalRobots: Int) -> [Int] {
    var input = input
    let coefficients = input.codes
      .map { code in
        code
          .map { String($0.description) }
          .dropLast()
          .joined()
      }
      .compactMap { Int($0) }

    return zip(coefficients, input.codes)
      .map { coefficient, code in 
        coefficient * input.getCost(keys: code, directionalRobots: directionalRobots)
      }
  }

  private static func sumComplexities(_ input: [Int]) -> Int {
    input.reduce(0, +)
  }
}
