import Foundation
import Combine
import SwiftTUI


class Day7ViewModel: DayViewModel {
  let title = Day.seven.rawValue

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

extension Day7ViewModel {
  enum Operator: String, CustomStringConvertible {
    case add = "+"
    case multiply = "*"
    case concatenate = "||"

    var description: String {
      self.rawValue
    }
  }

  struct Equation: DisplayableData {
    let answer: Int
    let values: [Int]

    var operators: [Operator]

    init(answer: Int, values: [Int]) {
      self.answer = answer
      self.values = values

      self.operators = [Operator](repeating: .add, count: values.count - 1)
    }

    func getResult() -> Int {
      var result = values[0]

      for (index, op) in operators.enumerated() {
        switch op {
          case .add:
            result += values[index + 1]
          case .multiply:
            result *= values[index + 1]
          case .concatenate:
            result = Int("\(result)\(values[index + 1])")!
        }
      }

      return result
    }

    func isValid() -> Bool {
      getResult() == answer
    }

    var displayData: [AttributedString] {
      var output = AttributedString("\(answer) = \(values[0])")

      for (index, op) in operators.enumerated() {
        output += AttributedString(" \(op) \(values[index + 1])")
      }

      output.foregroundColor = isValid() ? .green : .red

      return [output]
    }
  }
}

extension Day7ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day7.example
        case .puzzle: Inputs.Day7.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case makeValid
    case sumValidAnswers
    case makeValidWithConcatenation

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .makeValid: "Make equations valid"
        case .sumValidAnswers: "Sum valid answers"
        case .makeValidWithConcatenation: "Make equations valid using concatenation"
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

extension Day7ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipeline {
        StaticNode(id: StepID.loadData, value: input.inputValue)
        DynamicNode(id: StepID.parseData, computation: parseData)
        DynamicNode(id: StepID.makeValid, computation: makeValid)
        DynamicNode(id: StepID.sumValidAnswers, computation: sumValidAnswers)
      },
      .partTwo: DisplayablePipeline {
        StaticNode(id: StepID.loadData, value: input.inputValue)
        DynamicNode(id: StepID.parseData, computation: parseData)
        DynamicNode(id: StepID.makeValidWithConcatenation, computation: makeValidWithConcatenation)
        DynamicNode(id: StepID.sumValidAnswers, computation: sumValidAnswers)
      }
    ]
  }

  private static func parseData(_ input: String) -> [Equation] {
    var equations = [Equation]()
    
    for line in input.lines {
      let parts = line.split(separator: ":")

      let answer = Int(parts[0])!
      let values = parts[1].split(separator: " ").map { Int($0)! }

      equations.append(Equation(answer: answer, values: values))
    }

    return equations
  }

  private static func makeValid(_ input: [Equation]) -> [Equation] {
    var equations = input

    for (index, equation) in equations.enumerated() {
      guard let valid = findValidOperators(for: equation) else { continue }

      equations[index] = valid
    }

    return equations
  }

  private static func findValidOperators(
    for equation: Equation, 
    index: Int = 0, 
    usingConcatenation: Bool = false
  ) -> Equation? {
    guard !equation.isValid() else { return equation }
    guard index < equation.operators.count else { return nil }

    if let add = findValidOperators(
      for: equation, 
      index: index + 1,
      usingConcatenation: usingConcatenation
    ) {
      return add
    }

    var multiply = equation
    multiply.operators[index] = .multiply

    if let valid = findValidOperators(
      for: multiply, 
      index: index + 1,
      usingConcatenation: usingConcatenation
    ) {
      return valid
    }

    guard usingConcatenation else { return nil }

    var concatenate = equation
    concatenate.operators[index] = .concatenate

    return findValidOperators(
      for: concatenate, 
      index: index + 1, 
      usingConcatenation: usingConcatenation
    )
  }

  private static func sumValidAnswers(_ input: [Equation]) -> Int {
    input
      .filter { $0.isValid() }
      .map { $0.answer }
      .reduce(0, +)
  }

  private static func makeValidWithConcatenation(_ input: [Equation]) -> [Equation] {
    var equations = input

    for (index, equation) in equations.enumerated() {
      guard let valid = findValidOperators(
        for: equation, 
        usingConcatenation: true
      ) else { 
        continue
      }

      equations[index] = valid
    }

    return equations
  }
}
