import Foundation
import Combine
import SwiftTUI


class Day8ViewModel: DayViewModel {
  let title = Day.eight.rawValue

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

extension Day8ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day8.example
        case .puzzle: Inputs.Day8.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case markFirstAntinodes
    case markAllAntinodes
    case countMarkedCells

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .markFirstAntinodes: "Mark first antinodes"
        case .markAllAntinodes: "Mark all antinodes"
        case .countMarkedCells: "Count marked cells"
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

extension Day8ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .markFirstAntinodes, computation: markFirstAntinodes)
        .dynamicNode(id: .countMarkedCells, computation: countMarkedCells)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .dynamicNode(id: StepID.parseData, computation: parseData)
        .dynamicNode(id: StepID.markAllAntinodes, computation: markAllAntinodes)
        .dynamicNode(id: StepID.countMarkedCells, computation: countMarkedCells)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> MarkableGrid<Character> {
    MarkableGrid(grid: input)      
  }

  private static func markFirstAntinodes(
    _ input: MarkableGrid<Character>
  ) -> MarkableGrid<Character> {
    markAntinodes(grid: input, maxSteps: 1, useUnitVector: false)
  }

  private static func markAllAntinodes(
    _ input: MarkableGrid<Character>
  ) -> MarkableGrid<Character> {
    markAntinodes(grid: input, maxSteps: nil, useUnitVector: true)
  }

  private static func markAntinodes(
    grid: MarkableGrid<Character>, 
    maxSteps: Int?,
    useUnitVector: Bool
  ) -> MarkableGrid<Character> {
    var grid = grid

        let antennaTypes = Set<Character>(
      grid
        .enumerated()
        .map { $0.1 }
        .filter { $0 != "." }
    )

    for antennaType in antennaTypes {
      let positions = grid
        .enumerated()
        .filter { $0.1 == antennaType }
        .map { $0.0 }
      
      for i in 0..<positions.count { 
        for j in (i + 1)..<(positions.count) {
          var vector = positions[j] - positions[i]

          if useUnitVector {
            vector = vector.unitVector
            grid.markElement(at: positions[i], color: .red)
            grid.markElement(at: positions[j], color: .red)
          }

          var step = 1
          while step <= maxSteps ?? Int.max {
            let back = positions[i] - step * vector
            let forward = positions[j] + step * vector

            guard grid.isValid(position: back) || grid.isValid(position: forward) else { break }

            grid.markElement(at: back, color: .red)
            grid.markElement(at: forward, color: .red)

            step += 1
          }
        }
      }
    }

    return grid
  }

  private static func countMarkedCells(_ marks: MarkableGrid<Character>) -> Int {
    marks.countCells(marked: .red)
  }
}
