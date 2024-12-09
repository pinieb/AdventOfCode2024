import Foundation
import Combine
import SwiftTUI


class DayXViewModel: DayViewModel {
  let title = "" // Day.X.rawValue

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

extension DayXViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: "" // Inputs.DayX.example
        case .puzzle: "" // Inputs.DayX.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData

    var description: String {
      switch self {
        case .loadData: "Load data"
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

extension DayXViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .build()
    ]
  }
}
