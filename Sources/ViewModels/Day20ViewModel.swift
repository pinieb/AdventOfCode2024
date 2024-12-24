import Foundation
import Combine
import SwiftTUI


class Day20ViewModel: DayViewModel {
  let title = Day.twenty.rawValue

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

fileprivate enum GridCell: String, Equatable, CustomStringConvertible {
  case wall = "#"
  case empty = "."
  case start = "S"
  case end = "E"

  var description: String {
    self.rawValue
  }
}

fileprivate struct RaceTrack: DisplayableData {
  private var grid: MarkableGrid<GridCell>

  private let start: GridPosition
  private let end: GridPosition

  private var pathStep = [GridPosition: Int]()
  private var costs = [Int]()

  private(set) var shortcuts = [GridPosition: [GridPosition: Int]]()

  init(
    grid: MarkableGrid<GridCell>,
    start: GridPosition,
    end: GridPosition
  ) {
    self.grid = grid
    self.start = start
    self.end = end

    updateMarks()
  }

  private mutating func updateMarks() {
    grid.clearMarks()

    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        let position = GridPosition(row: row, column: column)

        switch grid.data[row][column] {
          case .wall: grid.markElement(at: position, color: .red)
          case .empty: grid.markElement(at: position, color: .gray)
          case .start, .end: grid.markElement(at: position, color: .green)
        }
      }
    }
  }

  mutating func findPath() {
    var frontier: [(position: GridPosition, cost: Int)] = [(start, 0)]
    var visited = Set<GridPosition>()

    costs = []
    pathStep = [:]
    var step = -1

    while !frontier.isEmpty {
      let current = frontier.removeFirst()

      guard !visited.contains(current.position) else {
        continue
      }

      step += 1
      costs.append(current.cost)
      pathStep[current.position] = step

      visited.insert(current.position)

      for direction in Direction.cardinal {
        let next = grid.makeNextPosition(from: current.position, direction: direction)

        guard grid.isValid(position: next), grid.data[next.row][next.column] != .wall else {
          continue
        }

        frontier.append(
          (position: next, cost: current.cost + 1)
        )
      }
    }
  }

  mutating func findShortcuts(steps: Int = 2) {
    for startPosition in pathStep.keys {
      for i in -steps...steps {
        for j in -steps...steps where abs(i) + abs(j) <= steps {
          let end = GridPosition(row: startPosition.row + i, column: startPosition.column + j)
          guard grid.isValid(position: end) else { continue }
          guard grid.data[end.row][end.column] != .wall else { continue }
          guard 
            let endStep = pathStep[end], 
            let startStep = pathStep[startPosition] 
          else { 
            continue 
          }

          let savings = (costs[endStep] - costs[startStep]) - end.manhattanDistance(to: startPosition)
          guard savings > 0 else { continue }

          shortcuts[startPosition, default: [:]][end] = savings
        }
      }
    }
  }

  var displayData: [AttributedString] {
    [AttributedString("Cost: \(costs.last ?? 0)")]
    + grid.displayData
  }
}

extension Day20ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day20.example
        case .puzzle: Inputs.Day20.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case findPath
    case findShortcuts
    case findShortcuts20
    case countShortcutsThatSave100

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .findPath: "Find path"
        case .findShortcuts: "Find shortcuts with length 2"
        case .findShortcuts20: "Find shortcuts with length 20"
        case .countShortcutsThatSave100: "Count shortcuts that save 100"
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

extension Day20ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findPath, computation: findPath)
        .dynamicNode(id: .findShortcuts, computation: findShortcuts)
        .dynamicNode(id: .countShortcutsThatSave100, computation: countShortcutsThatSave100)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findPath, computation: findPath)
        .dynamicNode(id: .findShortcuts20, computation: findShortcuts20)
        .dynamicNode(id: .countShortcutsThatSave100, computation: countShortcutsThatSave100)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> RaceTrack {
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

    return RaceTrack(grid: grid, start: start, end: end)
  }

  private static func findPath(_ input: RaceTrack) -> RaceTrack {
    var track = input

    track.findPath()

    return track
  }

  private static func findShortcuts(_ input: RaceTrack) -> RaceTrack {
    var track = input

    track.findShortcuts()

    return track
  }

    private static func findShortcuts20(_ input: RaceTrack) -> RaceTrack {
    var track = input

    track.findShortcuts(steps: 20)

    return track
  }

  private static func countShortcutsThatSave100(_ input: RaceTrack) -> Int {
    input.shortcuts.keys.flatMap { start in
      input.shortcuts[start]!.keys.map { input.shortcuts[start]![$0]! }
    }
    .count { $0 >= 100 }
  }
}
