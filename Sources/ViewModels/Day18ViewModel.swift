import Foundation
import Combine
import SwiftTUI


class Day18ViewModel: DayViewModel {
  let title = Day.eighteen.rawValue

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
  case obstacle = "#"
  case empty = "."

  var description: String {
    self.rawValue
  }
}

fileprivate struct PathNode: Equatable, Hashable {
  let position: GridPosition
  let cost: Int
}

fileprivate struct MemoryGrid: DisplayableData {
  private(set) var grid: MarkableGrid<GridCell>
  private(set) var corruption: [GridPosition]

  private(set) var timeStep = 0

  init(
    gridSize: Int,
    corruption: [GridPosition]
  ) {
    self.grid = MarkableGrid(
      elements: [[GridCell]](
        repeating: [GridCell](repeating: .empty, count: gridSize), 
        count: gridSize
      )
    )

    self.corruption = corruption
  }

  var displayData: [AttributedString] {
    grid.displayData
  }

  mutating func dropBytes(_ bytes: Int) {
    for _ in 0..<bytes {
      guard timeStep < corruption.count else { return }

      grid.markElement(at: corruption[timeStep], color: .red)
      grid.data[corruption[timeStep].row][corruption[timeStep].column] = .obstacle

      timeStep += 1
    }
  }

  mutating func reset() {
    grid = MarkableGrid(
      elements: [[GridCell]](
        repeating: [GridCell](repeating: .empty, count: grid.columns), 
        count: grid.rows
      )
    )

    timeStep = 0
  }

  func findBestPath() -> Int? {
    let end = GridPosition(row: grid.rows - 1, column: grid.columns - 1)

    var frontier = [PathNode(position: GridPosition(row: 0, column: 0), cost: 0)]
    var visited = Set<GridPosition>()

    while !frontier.isEmpty {
      let current = frontier.removeFirst()

      guard !visited.contains(current.position) else {
        continue
      }

      visited.insert(current.position)

      guard current.position != end else { 
        return current.cost
      }

      for direction in Direction.cardinal {
        let next = grid.makeNextPosition(from: current.position, direction: direction)
        guard 
          grid.isValid(position: next), 
          grid.data[next.row][next.column] == .empty
        else {
          continue
        }

        frontier.append(
          PathNode(position: next, cost: current.cost + 1)
        )
      }
    }

    return nil
  }
}

extension Day18ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day18.example
        case .puzzle: Inputs.Day18.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case parseDataAndDrop
    case findPath
    case findFirstBrokenState

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .parseDataAndDrop: "Parse data and handle initial drops"
        case .findPath: "Find path"
        case .findFirstBrokenState: "Find first broken state"
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

extension Day18ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseDataAndDrop, computation: parseDataAndDrop)
        .dynamicNode(id: .findPath, computation: findPath)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findFirstBrokenState, computation: findFirstBrokenState)
        .build()
    ]
  }

  private static func parseDataAndDrop(_ input: String) -> MemoryGrid {
    var grid = parseData(input)
    
    grid.dropBytes(Int(input.lines[1])!)
    
    return grid
  }

  private static func parseData(_ input: String) -> MemoryGrid {
    let lines = input.lines
    let gridSize = Int(lines[0]) ?? 0

    let blocks = lines[2...].map {
      let pos = $0.split(separator: ",")
      return GridPosition(row: Int(pos[1])!, column: Int(pos[0])!)
    }
    
    return MemoryGrid(
      gridSize: gridSize,
      corruption: blocks
    )
  }

  private static func findPath(_ input: MemoryGrid) -> Int {
    input.findBestPath() ?? -1
  }

  private static func findFirstBrokenState(_ input: MemoryGrid) -> GridPosition {
    var grid = input
    
    for i in 0..<grid.corruption.count {
      grid.dropBytes(1)
      
      guard grid.findBestPath() != nil else { 
        return grid.corruption[i]
      }
    }

    return GridPosition(row: -1, column: -1)
  }
}
