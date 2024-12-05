import Foundation
import Combine
import SwiftTUI

// MARK: - SubproblemData

private struct SubproblemData<StepID: Hashable & Equatable> {
  var steps: [Step<StepID>]
  var output: [StepID: StepOutput] = [:]
}

// MARK: - Steps

enum Day4StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
  case loadData
  case step2
  case step3

  var description: String {
    switch self {
      case .loadData: "Load data"
      case .step2: "Step 2"
      case .step3: "Step 3"
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

  private static let part1Steps = Day4StepID.allCases
  private static let part2Steps = Day4StepID.allCases
  
  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Day4Input.example
  @Published private(set) var selectedStep: Day4StepID

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
      return .text("Oops")
    }

    return .data(currentNode.displayableOutput)
  }

  init() {
    let part1Pipeline = DisplayablePipeline {
          StaticNode(id: Day4StepID.loadData, value: Day4Input.example.inputValue)
          DynamicNode(id: Day4StepID.step2) { (input: String) in 
            return 10
          }
          DynamicNode(id: Day4StepID.step3) { (input: Int) in 
            return "\(input) :)" 
          }
      }
    
    self.pipelines = [
      .partOne: part1Pipeline
    ]

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
