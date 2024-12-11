import Foundation
import Combine
import SwiftTUI


class Day10ViewModel: DayViewModel {
  let title = Day.ten.rawValue

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

// MARK: - Data types

struct Map: DisplayableData {
  private static let validDirections: [Direction] = [.north, .east, .south, .west]

  var grid: MarkableGrid<Int>
  private(set) var trailHeadScores: MarkableGrid<Int>?

  private var reachable9s: MarkableGrid<Int>?

  init(grid: [[Int]]) {
    let markableGrid = MarkableGrid(elements: grid)

    self.grid = Self.markTopology(grid: markableGrid)
    self.reachable9s = nil
    self.trailHeadScores = nil
  }

  private static func markTopology(grid: MarkableGrid<Int>) -> MarkableGrid<Int> {
    var grid = grid

    // Taken from https://coolors.co/palette/ff0000-ff8700-ffd300-deff0a-a1ff0a-0aff99-0aefff-147df5-580aff-be0aff
    let colors = [
      Color.trueColor(red: 190, green: 10, blue: 255),
      Color.trueColor(red: 88, green: 10, blue: 255),
      Color.trueColor(red: 20, green: 125, blue: 245),
      Color.trueColor(red: 10, green: 239, blue: 255),
      Color.trueColor(red: 153, green: 255, blue: 153),
      Color.trueColor(red: 161, green: 255, blue: 10),
      Color.trueColor(red: 255, green: 255, blue: 10),
      Color.trueColor(red: 255, green: 211, blue: 0),
      Color.trueColor(red: 255, green: 135, blue: 0),
      Color.trueColor(red: 255, green: 0, blue: 0)
    ]

    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        grid.markElement(
          at: GridPosition(row: row, column: column), 
          color: colors[grid.data[row][column] % colors.count]
        )
      }
    }

    return grid
  }

  mutating func scoreTrailHeads(allowMultiplePaths: Bool) {
    trailHeadScores = MarkableGrid(
      elements: [[Int]](
        repeating: [Int](repeating: 0, count: grid.columns), 
        count: grid.rows
      )
    )

    computeReachable9s(allowMultiplePaths: allowMultiplePaths)

    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        guard
          grid.data[row][column] == 0,
          let score = reachable9s?.data[row][column],
          score > 0
        else {
          continue
        }

        trailHeadScores?.data[row][column] = score
      }
    }

    trailHeadScores = Self.markTopology(grid: trailHeadScores!)
  }

  private mutating func computeReachable9s(allowMultiplePaths: Bool) {
    reachable9s = MarkableGrid(
      elements: [[Int]](
        repeating: [Int](repeating: 0, count: grid.columns), 
        count: grid.rows
      )
    )

    var nines = [GridPosition]()
    for row in 0..<grid.rows {
      for column in 0..<grid.columns {
        guard grid.data[row][column] == 9 else { continue }

        nines.append(GridPosition(row: row, column: column))
      }
    }

    for nine in nines {
      var frontier = [nine]
      var visited = Set<GridPosition>()

      while !frontier.isEmpty {
        let current = frontier.removeFirst()
        guard !visited.contains(current) || allowMultiplePaths else { continue }

        visited.insert(current)

        reachable9s?.data[current.row][current.column] += 1

        for direction in Self.validDirections {
          let next = grid.makeNextPosition(from: current, direction: direction)
          guard 
            grid.isValid(position: next), 
            grid.data[current.row][current.column] == grid.data[next.row][next.column] + 1
          else {
            continue
          }

          frontier.append(next)
        }
      }
    }

    reachable9s = Self.markTopology(grid: reachable9s!)
  }

  var displayData: [AttributedString] {
    grid.displayData
    + [AttributedString(" ")]
    + (reachable9s?.displayData ?? [])
    + [AttributedString(" ")]
    + (trailHeadScores?.displayData ?? [])
  }
}

extension Day10ViewModel {
  enum Input: String, InputProtocol {
    case smallExample = "Small example"
    case largeExample = "Large example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .smallExample: Inputs.Day10.smallExample
        case .largeExample: Inputs.Day10.largeExample
        case .puzzle: Inputs.Day10.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case rateTrailHeadsByDestinations
    case rateTrailHeadsByPaths
    case sumRatings

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .rateTrailHeadsByDestinations: "Rate trail heads by destinations"
        case .rateTrailHeadsByPaths: "Rate trail heads by paths"
        case .sumRatings: "Sum trail head ratings"
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

extension Day10ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .rateTrailHeadsByDestinations, computation: rateTrailHeadsByDestinations)
        .dynamicNode(id: .sumRatings, computation: sumRatings)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .rateTrailHeadsByPaths, computation: rateTrailHeadsByPaths)
        .dynamicNode(id: .sumRatings, computation: sumRatings)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> Map {
    let grid = input.lines.map { line in 
      let chars: [Character] = Array(line)

      return chars.map { Int(String($0))! }
    }

    return Map(grid: grid)
  }

  private static func rateTrailHeadsByDestinations(_ input: Map) -> Map {
    var map = input

    map.scoreTrailHeads(allowMultiplePaths: false)

    return map
  }

  private static func rateTrailHeadsByPaths(_ input: Map) -> Map {
    var map = input

    map.scoreTrailHeads(allowMultiplePaths: true)

    return map
  }

  private static func sumRatings(_ input: Map) -> Int { 
    var sum = 0
    
    input.trailHeadScores?.forEach {
      sum += $0
    }

    return sum
  }
}
