import Foundation
import Combine
import SwiftTUI

// MARK: - Steps

enum Day4StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
  case loadData
  case createSearchableGrid
  case findHorizontalXMAS
  case findVerticalXMAS
  case findDiagonalXMAS

  var description: String {
    switch self {
      case .loadData: "Load data"
      case .createSearchableGrid: "Create searchable grid"
      case .findHorizontalXMAS: "Find horizontal `XMAS`"
      case .findVerticalXMAS: "Find vertical `XMAS`"
      case .findDiagonalXMAS: "Find diagonal `XMAS`"
    }
  }

  var isFirstStep: Bool {
    switch self {
      case .loadData: return true
      default: return false
    }
  }
}

// MARK: - SearchableGrid

struct GridPosition {
  let row: Int
  let column: Int
}

enum Direction: CaseIterable {
  case south
  case southeast
  case east
  case northeast
  case north
  case northwest
  case west
  case southwest
}

struct SearchableGrid<Element: Equatable> {
  private let grid: [[Element]]

  private let columns: Int
  private let rows: Int

  private var wasFound: [[Bool]]

  init(elements: [[Element]]) {
    self.grid = elements

    self.rows = elements.count
    self.columns = elements.first?.count ?? 0

    self.wasFound = [[Bool]](repeating: [Bool](repeating: false, count: columns), count: rows)
  }

  mutating func markSequence(
    _ sequence: any Collection<Element>, 
    directions: [Direction] = Direction.allCases
  ) -> Int {
    guard !sequence.isEmpty else { return 0 }

    var markedCount = 0

    for row in 0..<rows {
      for column in 0..<columns {
        for direction in directions {
          if markSequence(
            sequence, 
            position: GridPosition(row: row, column: column), 
            direction: direction
          ) {
            markedCount += 1
          }
        }
      }
    }

    return markedCount
  }

  private mutating func markSequence(
    _ sequence: any Collection<Element>, 
    position: GridPosition, 
    direction: Direction
  ) -> Bool {
    guard let current = sequence.first else {
      return true
    }

    guard isValid(position: position) else { 
      return false
    }

    guard grid[position.row][position.column] == current else { 
      return false 
    }

    let nextPosition = makeNextPosition(from: position, direction: direction)

    let shouldMark = markSequence(sequence.dropFirst(), position: nextPosition, direction: direction)

    guard shouldMark else {
      return false
    }

    wasFound[position.row][position.column] = true
    return true
  }

  private func makeNextPosition(
    from position: GridPosition, 
    direction: Direction
  ) -> GridPosition {
    let offset: GridPosition
    switch direction {
      case .south:
        offset = GridPosition(row: 1, column: 0)
      case .southeast:
        offset = GridPosition(row: 1, column: 1)
      case .east:
        offset = GridPosition(row: 0, column: 1)
      case .northeast:
        offset = GridPosition(row: -1, column: 1)
      case .north:
        offset = GridPosition(row: -1, column: 0)
      case .northwest:
        offset = GridPosition(row: -1, column: -1)
      case .west:
        offset = GridPosition(row: 0, column: -1)
      case .southwest:
        offset = GridPosition(row: 1, column: -1)
    }

    return GridPosition(
      row: position.row + offset.row, 
      column: position.column + offset.column
    )
  }

  private func isValid(position: GridPosition) -> Bool {
    guard position.row >= 0, position.row < rows else { return false }
    guard position.column >= 0, position.column < columns else { return false }

    return true
  }
}

extension SearchableGrid: DisplayableData {
  var displayData: [AttributedString] {
    var output = [AttributedString]()
    
    for row in 0..<rows {
      var outputRow = AttributedString("")
      
      for col in 0..<columns {
        var cell = AttributedString("\(grid[row][col])")

        if wasFound[row][col] {
          cell.foregroundColor = .green
        }

        outputRow += cell
      }

      output.append(outputRow)
    }

    return output
  }
}

// MARK: - View model

class Day4ViewModel: DayViewModel {
  private struct SearchableGridAndCount<Element: Equatable>: DisplayableData {
    let grid: SearchableGrid<Element>
    let count: Int

    var displayData: [AttributedString] {
      var countLabel = AttributedString("Matches: ")
      countLabel.foregroundColor = .red

      var count = AttributedString("\(count)")
      count.bold = true

      return [countLabel + count] + [AttributedString(" ")] + grid.displayData
    }
  }

  private static func makePipelines(input: Day4Input) -> [Subproblem: DisplayablePipeline<Day4StepID>] {
    [
      .partOne: DisplayablePipeline {
        StaticNode(id: Day4StepID.loadData, value: input.inputValue)
        DynamicNode(id: Day4StepID.createSearchableGrid) { (input: String) in 
          SearchableGrid(elements: input.lines.map { Array($0) })
        }
        DynamicNode(id: Day4StepID.findHorizontalXMAS) { (grid: SearchableGrid<Character>) in 
          var grid = grid
          let count = grid.markSequence("XMAS", directions: [.east, .west])
          
          return SearchableGridAndCount(grid: grid, count: count)
        }
        DynamicNode(id: Day4StepID.findVerticalXMAS) { (input: SearchableGridAndCount<Character>) in 
          var grid = input.grid
          let count = input.count + grid.markSequence("XMAS", directions: [.north, .south])
          
          return SearchableGridAndCount(grid: grid, count: count)
        }
        DynamicNode(id: Day4StepID.findDiagonalXMAS) { (input: SearchableGridAndCount<Character>) in 
          var grid = input.grid
          let count = input.count + grid.markSequence(
            "XMAS", 
            directions: [.northeast, .southeast, .northwest, .southwest]
          )
          
          return SearchableGridAndCount(grid: grid, count: count)
        }
      }
    ]
  }
  
  @Published var selectedPart = Subproblem.partOne
  @Published private(set) var selectedStep: Day4StepID

  @Published var selectedInput = Day4Input.example {
    didSet {
      resetState()
    }
  }

  @Published private var pipelines: [Subproblem: DisplayablePipeline<Day4StepID>]

  var steps: [Step<Day4StepID>] {
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
    let input = Day4Input.example
    self.selectedInput = input
    self.pipelines = Self.makePipelines(input: input)
    self.selectedStep = .loadData
  }

  private func resetState() {
    self.pipelines = Self.makePipelines(input: selectedInput)
    self.selectedStep = .loadData
  }

  func runStep(id: Day4StepID) {
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

// MARK: - Input

enum Day4Input: String, InputProtocol {
  case example = "Example"
  case puzzle = "Puzzle"

  var inputValue: String {
    switch self {
      case .example: Inputs.Day4.example
      case .puzzle: Inputs.Day4.puzzle
    }
  }
}
