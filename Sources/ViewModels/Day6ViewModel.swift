import Foundation
import Combine
import SwiftTUI


class Day6ViewModel: DayViewModel {
  let title = Day.five.rawValue

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

extension Day6ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day6.example
        case .puzzle: Inputs.Day6.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case findGuardCoverage
    case countMarkedCells
    case findNewBarrelLocations

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .findGuardCoverage: "Find guard coverage"
        case .countMarkedCells: "Count marked cells"
        case .findNewBarrelLocations: "Find barrel locations"
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

extension Day6ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipeline {
        StaticNode(id: StepID.loadData, value: input.inputValue)
        DynamicNode(id: StepID.parseData, computation: parseData)
        DynamicNode(id: StepID.findGuardCoverage, computation: findGuardCoverage)
        DynamicNode(id: StepID.countMarkedCells, computation: countMarkedCells)
      },
      .partTwo: DisplayablePipeline {
        StaticNode(id: StepID.loadData, value: input.inputValue)
        DynamicNode(id: StepID.parseData, computation: parseData)
        DynamicNode(id: StepID.findNewBarrelLocations, computation: findNewBarrelLocations)
        DynamicNode(id: StepID.countMarkedCells, computation: countMarkedCells)
      }
    ]
  }

  private static func parseData(_ input: String) -> MarkableGrid<Character> {
    var marks = MarkableGrid(elements: input.lines.map { Array($0) })

    for row in 0..<marks.rows {
      for column in 0..<marks.columns {
        if marks.data[row][column] == "#" {
          marks.markElement(at: GridPosition(row: row, column: column), color: .red)
        } else if marks.data[row][column] != "." {
          marks.markElement(at: GridPosition(row: row, column: column), color: .green)
        }
      }
    }

    return marks
  }

  private static func findGuardCoverage(_ input: MarkableGrid<Character>) -> MarkableGrid<Character> {
    simulateSteps(input).path
  }

  private static func simulateSteps(_ input: MarkableGrid<Character>) -> (path: MarkableGrid<Character>, isLoop: Bool) {
    var marks = input
    
    let directions: [Direction] = [.north, .east, .south, .west]
    let directionChars: [Character] = ["^", ">", "v", "<"]

    var guardPosition = GridPosition(row: -1, column: -1)
    var guardDirection = -1
    for row in 0..<marks.rows {
      for column in 0..<marks.columns {
        switch marks.data[row][column] {
          case "^":
            guardPosition = GridPosition(row: row, column: column)
            guardDirection = 0
          case ">":
            guardPosition = GridPosition(row: row, column: column)
            guardDirection = 1
          case "v":
            guardPosition = GridPosition(row: row, column: column)
            guardDirection = 2
          case "<":
            guardPosition = GridPosition(row: row, column: column)
            guardDirection = 3
          default: break
        }
      }
    }

    guard marks.isValid(position: guardPosition), guardDirection != -1 else {
      return (marks, false)
    }

    var visited = [GridPosition: Set<Int>]()

    while marks.isValid(position: guardPosition) {
      guard visited[guardPosition]?.contains(guardDirection) != true else {
        return (marks, true)
      }

      visited[guardPosition, default: Set<Int>()].insert(guardDirection)

      let next = marks.makeNextPosition(from: guardPosition, direction: directions[guardDirection])

      marks.data[guardPosition.row][guardPosition.column] = "."
      marks.markElement(at: guardPosition, color: .green)

      if !marks.isValid(position: next) {
        break
      }

      if marks.data[next.row][next.column] == "#" {
        guardDirection += 1
        guardDirection %= directions.count
      } else {
        guardPosition = next
      }

      marks.data[guardPosition.row][guardPosition.column] = directionChars[guardDirection]
    }

    return (marks, false)
  }

  private static func countMarkedCells(_ marks: MarkableGrid<Character>) -> Int {
    var count = 0
    
    for row in 0..<marks.rows {
      for column in 0..<marks.columns {
        if marks.marks[row][column] == .green {
          count += 1
        }
      }
    }

    return count
  }

  private static func findNewBarrelLocations(
    _ input: MarkableGrid<Character>
  ) -> MarkableGrid<Character> {
    let pathWithoutBarrels = simulateSteps(input).path

    var barrels = input
    barrels.clearMarks()

    for row in 0..<pathWithoutBarrels.rows {
      for column in 0..<pathWithoutBarrels.columns {
        guard pathWithoutBarrels.marks[row][column] == .green else {
          continue
        }

        guard input.data[row][column] == "." else { continue }

        var newBarrelGrid = input
        newBarrelGrid.data[row][column] = "#"

        guard simulateSteps(newBarrelGrid).isLoop else {
          continue
        }

        barrels.markElement(at: GridPosition(row: row, column: column), color: .green)
        barrels.data[row][column] = "O"
      }
    }

    return barrels
  }
}
