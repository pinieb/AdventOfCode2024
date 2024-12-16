import Foundation
import Collections
import Combine
import SwiftTUI


class Day16ViewModel: DayViewModel {
  let title = Day.sixteen.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.exampleOne {
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
    let input = Input.exampleOne
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

fileprivate enum GridCell: String, Equatable, CustomStringConvertible {
  case wall = "#"
  case empty = "."
  case start = "S"
  case end = "E"

  var description: String {
    self.rawValue
  }
}

fileprivate struct PathNode: Comparable, Equatable, Hashable {
  let facing: Direction
  let position: GridPosition
  let cost: Int

  static func < (lhs: PathNode, rhs: PathNode) -> Bool {
    lhs.cost < rhs.cost
  }
}

fileprivate struct ReindeerMaze: DisplayableData {
  private(set) var maze: MarkableGrid<GridCell>
  let start: GridPosition
  let end: GridPosition

  private(set) var pathCost: Int?

  init(
    maze: MarkableGrid<GridCell>,
    start: GridPosition,
    end: GridPosition
  ) {
    self.maze = maze
    self.start = start
    self.end = end

    updateMarks()
  }

  var displayData: [AttributedString] {
    maze.displayData
    + (pathCost != nil ? [AttributedString("Path cost: \(pathCost!)")] : [])
  }

  private mutating func updateMarks() {
    maze.clearMarks()

    for row in 0..<maze.rows {
      for column in 0..<maze.columns {
        let position = GridPosition(row: row, column: column)

        switch maze.data[row][column] {
          case .wall: maze.markElement(at: position, color: .red)
          case .empty: maze.markElement(at: position, color: .gray)
          case .start, .end: maze.markElement(at: position, color: .green)
        }
      }
    }
  }

  mutating func computePathCost() {
    var queue = Heap<PathNode>()
    queue.insert(PathNode(facing: .east, position: start, cost: 0))

    var seen = [GridPosition: Set<Direction>]()

    while !queue.isEmpty, let current = queue.popMin() {
      guard maze.data[current.position.row][current.position.column] != .end else {
        pathCost = current.cost
        return
      }

      guard seen[current.position]?.contains(current.facing) != true else { continue }
      seen[current.position, default: Set<Direction>()].insert(current.facing)

      let next = maze.makeNextPosition(from: current.position, direction: current.facing)
      if maze.isValid(position: next), maze.data[next.row][next.column] != .wall {
        queue.insert(
          PathNode(
            facing: current.facing,
            position: next,
            cost: current.cost + 1
          )
        )
      }

      let clockwise = current.facing.rotate(direction: .clockwise, mode: .cardinal)
      let counterClockwise = current.facing.rotate(direction: .counterClockwise, mode: .cardinal)

      queue.insert(
        PathNode(
          facing: clockwise,
          position: current.position, 
          cost: current.cost + 1000
        )
      )

      queue.insert(
        PathNode(
          facing: counterClockwise,
          position: current.position, 
          cost: current.cost + 1000
        )
      )
    }
  }

  func findAllBestPaths() -> Set<GridPosition> {
    var minCosts = [GridPosition: [Direction: Int]]()

    var frontier: [PathNode] = [
      .init(facing: .north, position: end, cost: 0),
      .init(facing: .east, position: end, cost: 0),
      .init(facing: .south, position: end, cost: 0),
      .init(facing: .west, position: end, cost: 0),
    ]

    while !frontier.isEmpty {
      let current = frontier.removeFirst()

      guard current.cost < (minCosts[current.position]?[current.facing] ?? Int.max) else {
        continue
      }

      minCosts[current.position, default: [:]][current.facing] = current.cost

      let next = maze.makeNextPosition(from: current.position, direction: current.facing.opposite)
      if maze.isValid(position: next), maze.data[next.row][next.column] != .wall {
        frontier.append(
          PathNode(
            facing: current.facing,
            position: next,
            cost: current.cost + 1
          )
        )
      }

      let clockwise = current.facing.rotate(direction: .clockwise, mode: .cardinal)
      let counterClockwise = current.facing.rotate(direction: .counterClockwise, mode: .cardinal)

      frontier.append(
        PathNode(
          facing: clockwise,
          position: current.position, 
          cost: current.cost + 1000
        )
      )

      frontier.append(
        PathNode(
          facing: counterClockwise,
          position: current.position, 
          cost: current.cost + 1000
        )
      )
    }

    guard let minCost = minCosts[start]?[.east] else { return Set() }

    var nodes = Set<GridPosition>()
    frontier = [PathNode(facing: .east, position: start, cost: minCost)]

    while !frontier.isEmpty {
      let current = frontier.removeFirst()
      nodes.insert(current.position)

      let next = maze.makeNextPosition(from: current.position, direction: current.facing)
      if let cost = minCosts[next]?[current.facing], cost == current.cost - 1 {
        frontier.append(PathNode(facing: current.facing, position: next, cost: cost))
      }

      let clockwise = current.facing.rotate(direction: .clockwise, mode: .cardinal)
      if let cost = minCosts[current.position]?[clockwise], cost == current.cost - 1000 {
        frontier.append(PathNode(facing: clockwise, position: current.position, cost: cost))
      }

      let counterClockwise = current.facing.rotate(direction: .counterClockwise, mode: .cardinal)
      if let cost = minCosts[current.position]?[counterClockwise], cost == current.cost - 1000 {
        frontier.append(PathNode(facing: counterClockwise, position: current.position, cost: cost))
      }
    }

    return nodes
  }
}

extension Day16ViewModel {
  enum Input: String, InputProtocol {
    case exampleOne = "Example one"
    case exampleTwo = "Example two"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .exampleOne: Inputs.Day16.exampleOne
        case .exampleTwo: Inputs.Day16.exampleTwo
        case .puzzle: Inputs.Day16.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case computePathCost
    case findAllBestPaths

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .computePathCost: "Compute path cost"
        case .findAllBestPaths: "Find all best paths"
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

extension Day16ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .computePathCost, computation: computePathCost)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .computePathCost, computation: computePathCost)
        .dynamicNode(id: .findAllBestPaths, computation: findAllBestPaths)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> ReindeerMaze {
    let grid = MarkableGrid(
      elements: input.lines.map {
        $0.map {
          GridCell(rawValue: String($0)) ?? .empty
        }
      }
    )

    var start = GridPosition(row: 0, column: 0)
    var end = GridPosition(row: 0, column: 0)
    grid.enumerated().forEach { position, value in
      if value == .start {
        start = position
      }

      if value == .end {
        end = position
      }
    }

    return ReindeerMaze(
      maze: grid,
      start: start,
      end: end
    )
  }

  private static func computePathCost(_ input: ReindeerMaze) -> ReindeerMaze {
    var maze = input

    maze.computePathCost()

    return maze
  }

  private static func findAllBestPaths(_ input: ReindeerMaze) -> Int {
    input.findAllBestPaths().count
  }
}
