import Foundation
import Combine
import RegexBuilder
import SwiftTUI

class Day14ViewModel: DayViewModel {
  let title = Day.fourteen.rawValue

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

struct Robot: DisplayableData, Identifiable {
  let id: Int

  var position: GridPosition
  let velocity: GridPosition

  var displayData: [AttributedString] {
    [
      AttributedString("--- Robot \(id) ---"),
      AttributedString("Position: (\(position))"),
      AttributedString("Velocity: (\(velocity))")
    ]
  }
}

struct RobotGrid: DisplayableData {
  var grid: MarkableGrid<String>
  var robots: [Robot]

  private(set) var step = 0

  var displayData: [AttributedString] {
    [AttributedString("Step: \(step)")]
    + grid.displayData
    // + robots.flatMap { $0.displayData }
  }

  mutating func runSteps(_ steps: Int) {
    var newGrid = MarkableGrid(
      elements: [[String]](
        repeating: [String](repeating: ".", count: grid.columns), 
        count: grid.rows
      )
    )

    for i in 0..<robots.count {
      robots[i].position += steps * robots[i].velocity
      robots[i].position = GridPosition(
        row: mod(robots[i].position.row, grid.rows), 
        column: mod(robots[i].position.column, grid.columns)
      )

      newGrid.data[robots[i].position.row][robots[i].position.column] = "■"
    }

    grid = newGrid
    step += steps
  }
}

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

extension Day14ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day14.example
        case .puzzle: Inputs.Day14.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case run100Steps
    case runUntilRobotPositionsAreUnique
    case computeSafetyScore

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .run100Steps: "Run 100 steps"
        case .runUntilRobotPositionsAreUnique: "Run until robots positions are unique"
        case .computeSafetyScore: "Compute safety score"
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

extension Day14ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .run100Steps, computation: run100Steps)
        .dynamicNode(id: .computeSafetyScore, computation: computeSafetyScore)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .repeatableNode(id: .runUntilRobotPositionsAreUnique, computation: runUntilRobotPositionsAreUnique)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> RobotGrid {
    let positionX = Reference<Int>()
    let positionY = Reference<Int>()

    let velocityX = Reference<Int>()
    let velocityY = Reference<Int>()

    let robotPattern = Regex {      
      "p="
      Capture(as: positionX) {
        Optionally { "-" }
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ","
      Capture(as: positionY) {
        Optionally { "-" }
        OneOrMore(.digit)
      } transform: { Int($0)! }

      " v="
      Capture(as: velocityX) {
        Optionally { "-" }
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ","
      Capture(as: velocityY) {
        Optionally { "-" }
        OneOrMore(.digit)
      } transform: { Int($0)! }
    }

    let columns: Int = 101
    let rows: Int = 103

    let matches = input.matches(of: robotPattern)
    let robots = matches.enumerated().map { index, match in
      var velocityX = match[velocityX]
      while velocityX < 0 {
        velocityX += columns
      }

      var velocityY = match[velocityY]
      while velocityY < 0 {
        velocityY += rows
      }

      return Robot(
        id: index,
        position: GridPosition(row: match[positionY], column: match[positionX]),
        velocity: GridPosition(row: velocityY, column: velocityX)
      )
    }

    var grid = MarkableGrid<String>(
      elements: [[String]](
        repeating: [String](repeating: ".", count: columns), 
        count: rows
      )
    )

    for robot in robots {
      grid.data[robot.position.row][robot.position.column] = "■"
    }

    return RobotGrid(grid: grid, robots: robots)
  }

  private static func run100Steps(_ input: RobotGrid) -> RobotGrid {
    var grid = input

    grid.runSteps(100)

    return grid
  }

  private static func runUntilRobotPositionsAreUnique(_ input: RobotGrid) -> RobotGrid {
    var grid = input

    while true {
      grid.runSteps(1)

      let positions = Set<GridPosition>(
        grid.robots.map { $0.position }
      )

      if positions.count == grid.robots.count { 
        break
      }
    }

    return grid
  }

  private static func computeSafetyScore(_ input: RobotGrid) -> Int {
    var scores = [0, 0, 0, 0]

    for robot in input.robots {
      if robot.position.row < input.grid.rows / 2 {
        if robot.position.column < input.grid.columns / 2 {
          scores[0] += 1
        } else if robot.position.column > input.grid.columns / 2 {
          scores[1] += 1
        }
      } else if robot.position.row > input.grid.rows / 2 {
        if robot.position.column < input.grid.columns / 2 {
          scores[2] += 1
        } else if robot.position.column > input.grid.columns / 2 {
          scores[3] += 1
        }
      }
    }

    return scores.reduce(1, *)
  }
}
