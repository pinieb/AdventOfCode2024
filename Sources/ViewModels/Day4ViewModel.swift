import Foundation
import Combine
import SwiftTUI

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

// MARK: - Steps

enum Day4StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
  case loadData
  case createSearchableGrid
  case findHorizontalXMAS
  case findVerticalXMAS
  case findForwardDiagonalXMAS
  case findBackwardDiagonalXMAS
  case findDiagonallyCrossedMAS

  var description: String {
    switch self {
      case .loadData: "Load data"
      case .createSearchableGrid: "Create searchable grid"
      case .findHorizontalXMAS: "Find horizontal `XMAS`"
      case .findVerticalXMAS: "Find vertical `XMAS`"
      case .findForwardDiagonalXMAS: "Find forward diagonal `XMAS`"
      case .findBackwardDiagonalXMAS: "Find backward diagonal `XMAS`"
      case .findDiagonallyCrossedMAS: "Find diagonally crossed `MAS`"
    }
  }

  var isFirstStep: Bool {
    switch self {
      case .loadData: return true
      default: return false
    }
  }
}

// MARK: - View model

class Day4ViewModel: DayViewModel {
  private struct SearchableGridAndCount<Element: Equatable>: DisplayableData {
    let searchGrid: SearchableGrid<Element>
    var markedGrid: MarkableGrid<Element>
    var matches: [[(Element, GridPosition)]]

    var displayData: [AttributedString] {
      var countLabel = AttributedString("Matches: ")
      countLabel.foregroundColor = .red

      var count = AttributedString("\(matches.count)")
      count.bold = true

      return [countLabel + count] + [AttributedString(" ")] + markedGrid.displayData
    }
  }

  private static func makePipelines(input: Day4Input) -> [Subproblem: DisplayablePipeline<Day4StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: Day4StepID.loadData, value: input.inputValue)
        .dynamicNode(id: Day4StepID.createSearchableGrid) { (input: String) in 
          let chars = input.lines.map { Array($0) }
          let searchGrid = SearchableGrid(elements: chars)
          let markedGrid = MarkableGrid(elements: chars)

          return SearchableGridAndCount(
            searchGrid: searchGrid, 
            markedGrid: markedGrid, 
            matches: []
          )
        }
        .dynamicNode(id: Day4StepID.findHorizontalXMAS) { (data: SearchableGridAndCount<Character>) in
          var data = data 
          let matches = data.searchGrid.findSequence("XMAS", directions: [.east, .west])
          
          let positions = matches
            .flatMap { $0 }
            .map { $0.position }
          
          data.markedGrid.markElements(at: positions, color: .green)
          data.matches += matches

          return data
        }
        .dynamicNode(id: Day4StepID.findVerticalXMAS) { (data: SearchableGridAndCount<Character>) in
          var data = data 
          let matches = data.searchGrid.findSequence("XMAS", directions: [.north, .south])
          
          let positions = matches
            .flatMap { $0 }
            .map { $0.position }
          
          data.markedGrid.markElements(at: positions, color: .green)
          data.matches += matches

          return data
        }
        .dynamicNode(id: Day4StepID.findForwardDiagonalXMAS) { (data: SearchableGridAndCount<Character>) in
          var data = data 
          let matches = data.searchGrid.findSequence("XMAS", directions: [.northeast, .southwest])
          
          let positions = matches
            .flatMap { $0 }
            .map { $0.position }
          
          data.markedGrid.markElements(at: positions, color: .green)
          data.matches += matches

          return data
        }
        .dynamicNode(id: Day4StepID.findBackwardDiagonalXMAS) { (data: SearchableGridAndCount<Character>) in
          var data = data 
          let matches = data.searchGrid.findSequence("XMAS", directions: [.northwest, .southeast])
          
          let positions = matches
            .flatMap { $0 }
            .map { $0.position }
          
          data.markedGrid.markElements(at: positions, color: .green)
          data.matches += matches

          return data
        }
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: Day4StepID.loadData, value: input.inputValue)
        .dynamicNode(id: Day4StepID.createSearchableGrid) { (input: String) in 
          let chars = input.lines.map { Array($0) }
          let searchGrid = SearchableGrid(elements: chars)
          let markedGrid = MarkableGrid(elements: chars)

          return SearchableGridAndCount(
            searchGrid: searchGrid, 
            markedGrid: markedGrid, 
            matches: []
          )
        }
        .dynamicNode(id: Day4StepID.findDiagonallyCrossedMAS) { (data: SearchableGridAndCount<Character>) in
          var data = data 

          let forwardDiagonalMatches = data.searchGrid.findSequence(
            "MAS", 
            directions: [.northeast, .southwest]
          )

          let backwardDiagonalMatches = data.searchGrid.findSequence(
            "MAS", 
            directions: [.northwest, .southeast]
          )
          
          let forwardAs: [GridPosition: [(Character, GridPosition)]] = forwardDiagonalMatches
            .map { ($0[1].position, $0) }
            .reduce([:]) { result, current in
              var result = result
              
              result[current.0] = current.1

              return result
            }
          
          let crosses: [[(element: Character, position: GridPosition)]] = backwardDiagonalMatches
            .compactMap {
              guard let forward = forwardAs[$0[1].position] else { return nil }

              return $0 + forward
            }

          let positions = crosses
            .flatMap { $0 }
            .map { $0.position }

          data.markedGrid.markElements(at: positions, color: .green)
          data.matches += crosses

          return data
        }
        .build()
    ]
  }

  let title = Day.four.rawValue
  
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
