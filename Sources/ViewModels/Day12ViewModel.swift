import Foundation
import Combine
import SwiftTUI


class Day12ViewModel: DayViewModel {
  let title = Day.twelve.rawValue

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

struct Cell: Hashable, Equatable, CustomStringConvertible {
  let position: GridPosition
  let label: String
  let borders: Set<Direction>

  init(
    position: GridPosition,
    label: String,
    borders: Set<Direction>
  ) {
    self.position = position
    self.label = label
    self.borders = borders
  }

  var description: String { 
    label
  }

  var fullDescription: String {
    "(\(label), \(position), borders: \(borders))"
  }
}

struct Region: DisplayableData {
  let label: String
  let cells: Set<Cell>

  init(label: String, cells: Set<Cell>) {
    self.label = label
    self.cells = cells
  }

  var perimeterSize: Int {
    cells.map { $0.borders.count }.reduce(0, +)
  }

  var displayData: [AttributedString] {
    [
      AttributedString("Region (\(label))"),
      AttributedString("Total area: \(cells.count)"),
      AttributedString("Perimeter length: \(cells.map { $0.borders.count }.reduce(0, +))"),
      AttributedString("Cells: \(cells)")
    ]
  }

  func countSides() -> Int {
    struct WalkState: Hashable {
      let position: GridPosition
      let direction: Direction
    }

    var perimeterMap = [GridPosition: Cell]()
    cells
      .filter { !$0.borders.isEmpty }
      .forEach {
        perimeterMap[$0.position] = $0
      }

    var count = 0
    var seen = Set<WalkState>()

    var next = cells.first { $0.borders.contains(.west) && $0.borders.contains(.north)}
    var directionIndex = 0
    while let current = next {
      let travelDirection = Direction.cardinal[directionIndex]
      let state = WalkState(
        position: current.position, 
        direction: travelDirection
      )

      guard !seen.contains(state) else {
        break
      }

      seen.insert(state)

      let nextPosition: GridPosition
      switch travelDirection {
        case .north: 
          nextPosition = GridPosition(
            row: current.position.row - 1, 
            column: current.position.column
          )
        case .east: 
          nextPosition = GridPosition(
            row: current.position.row, 
            column: current.position.column + 1
          )
        case .west: 
          nextPosition = GridPosition(
            row: current.position.row, 
            column: current.position.column - 1
          )
        case .south: 
          nextPosition = GridPosition(
            row: current.position.row + 1, 
            column: current.position.column
          )
        default: nextPosition = current.position
      }

      guard let nextCell = perimeterMap[nextPosition] else { 
        directionIndex += 1
        directionIndex %= 4
        count += 1
        continue
      }

      let left = Direction.cardinal[(directionIndex + 3) % 4]
      guard nextCell.borders.contains(left) else {
        directionIndex += 3
        directionIndex %= 4
        count += 1
        continue
      }

      next = nextCell
    }

    return count
  }
}

struct FlowerField: DisplayableData {
  private static let colorDictionary: [String: Color] = [
    "A": Color.trueColor(red: 255, green: 0, blue: 0), // Vivid Red
    "B": Color.trueColor(red: 255, green: 165, blue: 0), // Orange Burst
    "C": Color.trueColor(red: 255, green: 255, blue: 0), // Golden Yellow
    "D": Color.trueColor(red: 0, green: 255, blue: 0), // Lime Green
    "E": Color.trueColor(red: 0, green: 255, blue: 255), // Turquoise
    "F": Color.trueColor(red: 0, green: 0, blue: 255), // Sky Blue
    "G": Color.trueColor(red: 128, green: 0, blue: 128), // Deep Purple
    "H": Color.trueColor(red: 255, green: 0, blue: 255), // Magenta
    "I": Color.trueColor(red: 255, green: 127, blue: 80), // Coral Pink
    "J": Color.trueColor(red: 250, green: 128, blue: 114), // Salmon
    "K": Color.trueColor(red: 255, green: 218, blue: 185), // Peach
    "L": Color.trueColor(red: 255, green: 250, blue: 205), // Lemon Yellow
    "M": Color.trueColor(red: 0, green: 255, blue: 127), // Spring Green
    "N": Color.trueColor(red: 127, green: 255, blue: 212), // Aquamarine
    "O": Color.trueColor(red: 0, green: 191, blue: 255), // Cerulean Blue
    "P": Color.trueColor(red: 230, green: 230, blue: 250), // Lavender
    "Q": Color.trueColor(red: 255, green: 105, blue: 180), // Hot Pink
    "R": Color.trueColor(red: 148, green: 0, blue: 211), // Electric Purple
    "S": Color.trueColor(red: 57, green: 255, blue: 20), // Neon Green
    "T": Color.trueColor(red: 0, green: 128, blue: 128), // Teal
    "U": Color.trueColor(red: 46, green: 139, blue: 87), // Ocean Blue
    "V": Color.trueColor(red: 65, green: 105, blue: 225), // Royal Blue
    "W": Color.trueColor(red: 218, green: 112, blue: 214), // Orchid
    "X": Color.trueColor(red: 255, green: 192, blue: 203), // Rose
    "Y": Color.trueColor(red: 255, green: 215, blue: 180), // Apricot
    "Z": Color.trueColor(red: 189, green: 252, blue: 201)  // Mint
  ]

  private(set) var grid: MarkableGrid<Cell>
  private(set) var regions: [Region] = []

  init(grid: [[Cell]]) {
    self.grid = MarkableGrid(elements: grid)

    markFlowers()
  }

  private mutating func markFlowers() {
    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        grid.markElement(
          at: GridPosition(row: row, column: column), 
          color: Self.colorDictionary[grid.data[row][column].label]
        )
      }
    }
  }

  mutating func findRegions() {
    var regions = [Region]()

    var visited = Set<GridPosition>()
    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        let position = GridPosition(row: row, column: column)
        guard !visited.contains(position) else { continue }

        var cells = Set<Cell>()
        var frontier = [position]

        while !frontier.isEmpty {
          let current = frontier.removeFirst()
          guard !visited.contains(current) else { continue }

          cells.insert(grid.data[current.row][current.column])
          visited.insert(current)

          for direction in Direction.cardinal {
            let next = grid.makeNextPosition(from: current, direction: direction)
            guard grid.isValid(position: next) else { continue }
            guard grid.data[current.row][current.column].label == grid.data[next.row][next.column].label else { continue }

            frontier.append(next)
          }
        }

        regions.append(Region(label: grid.data[row][column].label, cells: cells))
      }
    }

    self.regions = regions
  }

  func countSides(of region: Region) -> Int {
    var sides = 0

    var previousWestCols = Set<Int>()
    var previousEastCols = Set<Int>()

    for row in 0..<grid.rows {
      var currentWestCols = Set<Int>()
      var currentEastCols = Set<Int>()
      for column in 0..<grid.columns {
        guard region.cells.contains(grid.data[row][column]) else { continue }

        if grid.data[row][column].borders.contains(.west) {
          currentWestCols.insert(column)
        }

        if grid.data[row][column].borders.contains(.east) {
          currentEastCols.insert(column)
        }
      }

      sides += currentWestCols.subtracting(previousWestCols).count
      sides += currentEastCols.subtracting(previousEastCols).count

      previousWestCols = currentWestCols
      previousEastCols = currentEastCols
    }

    var previousNorthRows = Set<Int>()
    var previousSouthRows = Set<Int>()

    for column in 0..<grid.columns {
      var currentNorthRows = Set<Int>()
      var currentSouthRows = Set<Int>()
      for row in 0..<grid.rows {
        guard region.cells.contains(grid.data[row][column]) else { continue }

        if grid.data[row][column].borders.contains(.north) {
          currentNorthRows.insert(row)
        }

        if grid.data[row][column].borders.contains(.south) {
          currentSouthRows.insert(row)
        }
      }

      sides += currentNorthRows.subtracting(previousNorthRows).count
      sides += currentSouthRows.subtracting(previousSouthRows).count

      previousNorthRows = currentNorthRows
      previousSouthRows = currentSouthRows
    }

    return sides
  }

  var displayData: [AttributedString] {
    var output = grid.displayData

    if !regions.isEmpty {
      output += [AttributedString(" ")]

      output += [AttributedString("Regions: \(regions.count)")]
    }

    return output
  }
}

extension Day12ViewModel {
  enum Input: String, InputProtocol {
    case smallExample = "Small example"
    case largeExample = "Large example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .smallExample: Inputs.Day12.smallExample
        case .largeExample: Inputs.Day12.largeExample
        case .puzzle: Inputs.Day12.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case findRegions
    case findCostOfPerimeterFencing
    case findCostOfSideFencing

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .findRegions: "Find regions"
        case .findCostOfPerimeterFencing: "Find cost of perimeter fencing"
        case .findCostOfSideFencing: "Find cost of side fencing"
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

extension Day12ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findRegions, computation: findRegions)
        .dynamicNode(id: .findCostOfPerimeterFencing, computation: findCostOfPerimeterFencing)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findRegions, computation: findRegions)
        .dynamicNode(id: .findCostOfSideFencing, computation: findCostOfSideFencing)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> FlowerField {
    let grid = MarkableGrid(grid: input)

    var cells = [[Cell]]()

    for (position, label) in grid.enumerated() {
      if position.row == cells.count { 
        cells.append([])
      }

      var borders = Set<Direction>()
      for direction in Direction.cardinal {
        let next = grid.makeNextPosition(from: position, direction: direction)

        guard grid.isValid(position: next) else {
          borders.insert(direction)
          continue
        }

        guard 
          grid.data[next.row][next.column] != grid.data[position.row][position.column]
        else {
          continue
        }

        borders.insert(direction)
      }

      cells[cells.count - 1].append(
        Cell(
          position: position,
          label: String(label),
          borders: borders
        )
      )
    }

    return FlowerField(grid: cells)
  }

  private static func findRegions(_ input: FlowerField) -> FlowerField {
    var field = input

    field.findRegions()

    return field
  }

  private static func findCostOfPerimeterFencing(_ input: FlowerField) -> Int {
    var total = 0
    
    for region in input.regions {
      total += region.perimeterSize * region.cells.count
    }

    return total
  }

  private static func findCostOfSideFencing(_ input: FlowerField) -> Int {
    var total = 0
    
    for region in input.regions {
      total += input.countSides(of: region) * region.cells.count
    }

    return total
  }
}
