import Foundation
import Combine
import SwiftTUI


class Day15ViewModel: DayViewModel {
  let title = Day.fifteen.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.smallExample {
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
    let input = Input.smallExample
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
  case empty = "."
  case box = "O"
  case robot = "@"
  case wall = "#"
  case boxL = "["
  case boxR = "]"

  var isBox: Bool {
    switch self {
      case .box, .boxL, .boxR: true
      default: false
    }
  }

  var isExpandedBox: Bool {
    switch self {
      case .boxL, .boxR: true
      default: false
    }
  }

  var description: String { self.rawValue }
}

fileprivate struct ProblemData: DisplayableData {
  var grid: MarkableGrid<GridCell>
  var robotPosition: GridPosition
  var robotMoves: [Direction]

  init(
    grid: MarkableGrid<GridCell>,
    robotPosition: GridPosition,
    robotMoves: [Direction]
  ) {
    self.grid = grid
    self.robotPosition = robotPosition
    self.robotMoves = robotMoves

    updateMarks()
  }

  var displayData: [AttributedString] {
    let moves = robotMoves.map {
      switch $0 {
        case .north: "^"
        case .south: "v"
        case .west: "<"
        case .east: ">"
        default: ""
      }
    }

    return grid.displayData
    + [AttributedString(" ")]
    + [AttributedString("Robot position: \(robotPosition)")]
    // + [AttributedString("Robot moves: \(moves)")]
  }

  private mutating func updateMarks() {
    grid.clearMarks()

    for (position, cell) in grid.enumerated() {
      switch cell {
        case .box, .boxL, .boxR: grid.markElement(at: position, color: .green)
        case .robot: grid.markElement(at: position, color: .white)
        case .wall: grid.markElement(at: position, color: .red)
        case .empty: grid.markElement(at: position, color: .gray)
      }
    }
  }

  func getGPS() -> Int {
    var gps = 0
    
    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        guard grid.data[row][column] == .box || grid.data[row][column] == .boxL else { continue }
        gps += 100 * row + column
      }
    }

    return gps
  }

  mutating func processStep() {
    guard !robotMoves.isEmpty else { return }
    let move = robotMoves.removeFirst()
    let newRobotPosition = grid.makeNextPosition(from: robotPosition, direction: move)

    moveBoxes(from: newRobotPosition, direction: move)

    if grid.data[newRobotPosition.row][newRobotPosition.column] == .empty {
      grid.data[robotPosition.row][robotPosition.column] = .empty
      grid.data[newRobotPosition.row][newRobotPosition.column] = .robot

      robotPosition = newRobotPosition
    }

    updateMarks()
  }

  private mutating func moveBoxes(from position: GridPosition, direction: Direction) {
    guard grid.data[position.row][position.column].isBox else { return }

    if grid.data[position.row][position.column].isExpandedBox { 
      moveExpandedBoxes(from: position, direction: direction)
      return
    }

    let nextPosition = grid.makeNextPosition(from: position, direction: direction)
    guard grid.data[nextPosition.row][nextPosition.column] != .wall else { return }

    if grid.data[nextPosition.row][nextPosition.column] == .box {
      moveBoxes(from: nextPosition, direction: direction)
    }

    guard grid.data[nextPosition.row][nextPosition.column] == .empty else { return }

    grid.data[position.row][position.column] = .empty
    grid.data[nextPosition.row][nextPosition.column] = .box
  }

  private mutating func moveExpandedBoxes(
      from position: GridPosition, 
      direction: Direction
    ) {
    guard grid.data[position.row][position.column].isExpandedBox else { return }
    guard grid.data[position.row][position.column] == .boxL else { 
      moveExpandedBoxes(
        from: grid.makeNextPosition(from: position, direction: .west), 
        direction: direction
      )

      return 
    }

    switch direction {
      case .west, .east: 
        moveExpandedHorizontally(from: position, direction: direction)
        return
      case .north, .south:
        moveExpandedVertically(from: position, direction: direction)
        return
      default: return
    }
  }

  private mutating func moveExpandedHorizontally(from position: GridPosition, direction: Direction) {
    var next = grid.makeNextPosition(from: position, direction: direction)
    while grid.data[next.row][next.column].isBox {
      next = grid.makeNextPosition(from: next, direction: direction)
    }

    guard grid.data[next.row][next.column] == .empty else { return }

    var startColumn: Int
    var endColumn: Int
    if next.column > position.column {
      startColumn = position.column + 1
      endColumn = next.column

      grid.data[position.row][position.column] = .empty
    } else {
      startColumn = next.column
      endColumn = position.column

      let clear = grid.makeNextPosition(from: position, direction: .east)
      grid.data[clear.row][clear.column] = .empty
    }

    for offset in 0...(endColumn - startColumn) {
      grid.data[position.row][startColumn + offset] = offset.isMultiple(of: 2) ? .boxL : .boxR
    }
  }

  private mutating func moveExpandedVertically(from position: GridPosition, direction: Direction) {
    var lefts = [[Int]]()
    if grid.data[position.row][position.column] == .boxL {
      lefts.append([position.column])
    } else if grid.data[position.row][position.column] == .boxR {
      lefts.append([position.column - 1])
    } else {
      return
    }

    var next = grid.makeNextPosition(from: position, direction: direction)
    while grid.isValid(position: next) {
      var newLefts = [Int]()

      for left in lefts.last ?? [] {
        guard grid.data[next.row][left] != .wall, grid.data[next.row][left + 1] != .wall else {
          return
        }

        if grid.data[next.row][left] == .boxL {
          newLefts.append(left)
        } else if grid.data[next.row][left] == .boxR {
          newLefts.append(left - 1)
        }
        
        if grid.data[next.row][left + 1] == .boxL {
          newLefts.append(left + 1)
        }
      }

      guard !newLefts.isEmpty else { break }
      lefts.append(newLefts)

      next = grid.makeNextPosition(from: next, direction: direction)
    }

    let newDirection = direction.opposite
    while next.row != position.row  {
      let current = next
      next = grid.makeNextPosition(from: next, direction: newDirection)

      for left in lefts.popLast() ?? [] {
        grid.data[current.row][left] = .boxL
        grid.data[current.row][left + 1] = .boxR
        grid.data[next.row][left] = .empty
        grid.data[next.row][left + 1] = .empty
      }
    }
  }
}

extension Day15ViewModel {
  enum Input: String, InputProtocol {
    case tinyExample = "Tiny example"
    case smallExample = "Small example"
    case largeExample = "Large example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .tinyExample: Inputs.Day15.tinyExample
        case .smallExample: Inputs.Day15.smallExample
        case .largeExample: Inputs.Day15.largeExample
        case .puzzle: Inputs.Day15.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case processStep
    case processAllSteps
    case computeGPS

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .processStep: "Process step"
        case .processAllSteps: "Process all steps"
        case .computeGPS: "Compute GPS"
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

extension Day15ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parsePart1)
        // .repeatableNode(id: .processStep, computation: processStep)
        .dynamicNode(id: .processAllSteps, computation: processAllSteps)
        .dynamicNode(id: .computeGPS, computation: computeGPS)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parsePart2)
        // .repeatableNode(id: .processStep, computation: processStep)
        .dynamicNode(id: .processAllSteps, computation: processAllSteps)
        .dynamicNode(id: .computeGPS, computation: computeGPS)
        .build()
    ]
  }

  private static func parsePart1(_ input: String) -> ProblemData {
    parseData(input, expandGrid: false)
  }

  private static func parsePart2(_ input: String) -> ProblemData {
    parseData(input, expandGrid: true)
  }

  private static func parseData(_ input: String, expandGrid: Bool) -> ProblemData {
    var lineIndex = 0
    let lines = input.split(separator: "\n", omittingEmptySubsequences: false)

    var robotPosition = GridPosition(row: 0, column: 0)

    var grid = [[GridCell]]()
    while lines[lineIndex] != "" {
      var gridLine = [GridCell]()
      
      for (index, char) in lines[lineIndex].enumerated() {
        let cell = GridCell(rawValue: String(char)) ?? .empty
        
        if expandGrid {
          switch cell {
            case .box:
              gridLine.append(.boxL)
              gridLine.append(.boxR)
            case .empty:
              gridLine.append(.empty)
              gridLine.append(.empty)
            case .robot:
              gridLine.append(.robot)
              gridLine.append(.empty)
            case .wall:
              gridLine.append(.wall)
              gridLine.append(.wall)
            default: break
          }
        } else {
          gridLine.append(cell)
        }

        if cell == .robot {
          robotPosition = GridPosition(row: lineIndex, column: (expandGrid ? 2 : 1) * index)
        }
      }

      grid.append(gridLine)

      lineIndex += 1
    }

    var robotMoves = [Direction]()
    while lineIndex < lines.count {
      for char in lines[lineIndex] {
        switch char {
          case "<":
            robotMoves.append(.west)
          case ">":
            robotMoves.append(.east)
          case "^":
            robotMoves.append(.north)
          case "v":
            robotMoves.append(.south)
          default: break
        }
      }

      lineIndex += 1
    }

    return ProblemData(
      grid: MarkableGrid(elements: grid), 
      robotPosition: robotPosition, 
      robotMoves: robotMoves
    )
  }

  private static func processStep(_ input: ProblemData) -> ProblemData {
    var data = input

    data.processStep()

    return data
  }

  private static func processAllSteps(_ input: ProblemData) -> ProblemData {
    var data = input

    while !data.robotMoves.isEmpty {
      data.processStep()
    }

    return data
  }

  private static func computeGPS(_ input: ProblemData) -> Int {
    input.getGPS()
  }
}
