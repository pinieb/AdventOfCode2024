import Foundation
import Combine
import RegexBuilder
import SwiftTUI

enum Day3StepID: Int, Hashable, Equatable, CaseIterable, CustomStringConvertible {
  case loadData = 1
  case findEnabledAreas
  case findValidMulCommands
  case runMulCommands
  case sumProducts

  var description: String {
    let title: String
    
    switch self {
      case .loadData: 
        title = "Load data"
      case .findEnabledAreas:
        title = "Find enabled areas"
      case .findValidMulCommands:
        title = "Find valid `MUL` commands"
      case .runMulCommands:
        title = "Run `MUL` commands"
      case .sumProducts:
        title = "Sum products"
    }

    return title
  }

  var isFirstStep: Bool {
    switch self {
      case .loadData: return true
      default: return false
    }
  }
}

typealias Day3Step = Step<Day3StepID>

enum Day3DataState: Equatable {
  case unloaded
  case loaded(text: String)
  case enabledAreas(text: [String])
  case validCommands(highlightedText: [AttributedString], commands: [MultiplyCommand])
  case runCommands(lines: [String], products: [Int])
  case sumProducts(text: String)
}

struct MultiplyCommand: Equatable, CustomStringConvertible {
  private let lhs: Int
  private let rhs: Int

  init(_ lhs: Int, _ rhs: Int) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    "mul(\(lhs),\(rhs))"
  }

  func run() -> Int {
    lhs * rhs
  }
}

private struct SubproblemData: Equatable {
  var steps: [Day3Step]
  var dataState = Day3DataState.unloaded
}

enum Day3InputOption: Int, CaseIterable, Hashable, Equatable {
  case example1
  case example2
  case puzzle
}

extension Day3InputOption: Identifiable {
  var id: Int { self.rawValue }
}

extension Day3InputOption: SelectionItem {
  var label: String {
    switch self {
      case .example1: "Example 1"
      case .example2: "Example 2"
      case .puzzle: "Puzzle"
    }
  }
}

class Day3ViewModel: ObservableObject {
  private static let partOneSteps: [Day3StepID] = [
    .loadData,
    .findValidMulCommands,
    .runMulCommands,
    .sumProducts,
  ]

  private static let partTwoSteps = Day3StepID.allCases

  var steps: [Day3Step] { subproblemData[selectedPart]!.steps }
  var dataState: Day3DataState { subproblemData[selectedPart]!.dataState }

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Day3InputOption.example1 {
    didSet {
      self.subproblemData = Self.makeSubproblemData()
    }
  }

  @Published private var subproblemData: [Subproblem : SubproblemData]

  init() {
    self.subproblemData = Self.makeSubproblemData()
  }

  private static func makeSubproblemData() -> [Subproblem: SubproblemData] {
    [
      .partOne: SubproblemData(
        steps: Self.partOneSteps.enumerated()
          .map { (index, id) in
            Step(
              id: id, 
              number: index + 1, 
              title: id.description, 
              state: id.isFirstStep ? .enabled : .disabled
            )
          }
      ),
      .partTwo: SubproblemData(
        steps: Self.partTwoSteps.enumerated()
          .map { (index, id) in
            Step(
              id: id, 
              number: index + 1, 
              title: id.description, 
              state: id.isFirstStep ? .enabled : .disabled
            )
          }
      )
    ]
  }

  func runStep(id: Day3Step.ID) {
    guard let index = steps.firstIndex(where: { $0.id == id }) else { 
      return 
    }
    
    var currentStep = steps[index]
    guard currentStep.state == .enabled else { return }

    switch id {
      case .loadData: loadData()
      case .findEnabledAreas: findEnabledAreas()
      case .findValidMulCommands: findValidMulCommands()
      case .runMulCommands: runMulCommands()
      case .sumProducts: sumProducts()
    }

    currentStep.state = .complete
    subproblemData[selectedPart]?.steps[index] = currentStep

    let nextIndex = index + 1
    guard nextIndex < steps.count else { return }

    subproblemData[selectedPart]?.steps[nextIndex].state = .enabled
  }

  private func loadData() {
    guard dataState == .unloaded else { return }

    var input: String
    switch selectedInput {
      case .example1:
        input = Inputs.day3Example1
      case .example2:
        input = Inputs.day3Example2
      case .puzzle:
        input = Inputs.day3Puzzle
    }

    input.replace("\n", with: "")

    subproblemData[selectedPart]?.dataState = .loaded(text: input)
  }

  private func findEnabledAreas() {
    guard case .loaded(let input) = dataState else {
      return
    }

    let doDontPattern = Regex {
      "do()"
      Capture {
        OneOrMore {
          NegativeLookahead { "don't()" }
          CharacterClass.any
        }
      }
      "don't()"
    }

    let enabledAreas = "do()\(input)don't()".matches(of: doDontPattern)
      .map { String($0.1) }
    
    subproblemData[selectedPart]?.dataState = .enabledAreas(text: enabledAreas)
  }

  private func findValidMulCommands() {
    let inputs: [String]
    switch dataState {
      case .loaded(let text) where selectedPart == .partOne:
        inputs = [text]
      case .enabledAreas(let areas) where selectedPart == .partTwo:
        inputs = areas
      default: return
    }

    let mulPattern = Regex {
      "mul("
      Capture {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ","
      Capture {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      ")"
    }

    var commands = [MultiplyCommand]()
    var matchedStrings = [AttributedString]()
    
    for input in inputs {
      var matchedString = AttributedString(input)
      let matches = input.matches(of: mulPattern)
      for match in matches {
        let lhs = match.output.1
        let rhs = match.output.2

        commands.append(MultiplyCommand(lhs, rhs))

        guard 
          let matchStart = AttributedString.Index(match.range.lowerBound, within: matchedString),
          let matchEnd = AttributedString.Index(match.range.upperBound, within: matchedString) 
        else {
          continue
        }

        let range = matchStart..<matchEnd
        matchedString[range].foregroundColor = .green
      }

      matchedStrings.append(matchedString)
    }

    subproblemData[selectedPart]?.dataState = .validCommands(
      highlightedText: matchedStrings, 
      commands: commands
    )
  }

  private func runMulCommands() {
    guard case .validCommands(_, let commands) = dataState else {
      return
    }

    var lines = [String]()
    var products = [Int]()
    for command in commands {
      let product = command.run()
      lines.append("\(command.description) = \(product)")
      products.append(product)
    }

    subproblemData[selectedPart]?.dataState = .runCommands(lines: lines, products: products)
  }

  private func sumProducts() {
    guard case .runCommands(_, let products) = dataState else {
      return
    }

    let sum = products.reduce(0, +)

    subproblemData[selectedPart]?.dataState = .sumProducts(text: "Sum of products: \(sum)")
  }
}
