import Foundation
import Combine
import SwiftTUI


class Day19ViewModel: DayViewModel {
  let title = Day.nineteen.rawValue

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

// MARK: - Data types

class TrieNode {
  private(set) var children = [Character: TrieNode]()
  
  func add(word: String) {
    var node = self
    for char in word {
      if node.children[char] == nil {
        node.children[char] = TrieNode()
      }

      node = node.children[char]!
    }

    node.children["."] = TrieNode()
  }

  func contains(word: String) -> Bool {
    var node = self
    for char in word {
      guard let child = node.children[char] else { return false }

      node = child
    }

    return node.children["."] != nil
  }
}

fileprivate struct ProblemData: DisplayableData {
  private var trie = TrieNode()

  private var isValid = [String: Int]()
  private var cache = [String: Int]()

  private let words: [String]
  private let patterns: [String]

  init(
    words: [String],
    patterns: [String]
  ) {
    self.words = words
    self.patterns = patterns

    words.forEach { trie.add(word: $0) }
  }

  mutating func checkPatterns() {
    for pattern in patterns {
      var dp = [Int](repeating: 0, count: pattern.count + 1)
      dp[pattern.count] = 1

      for i in (0..<pattern.count).reversed() {
        for j in i..<pattern.count {
          let current = String(Array(pattern)[i...j])

          if trie.contains(word: current) {
            dp[i] += dp[j + 1]
          }
        }
      }

      isValid[pattern, default: 0] += dp[0]
    }
  }

  var displayData: [AttributedString] {
    [AttributedString("Valid: \(isValid.values.count { $0 > 0 })")]
    + [AttributedString("Combos: \(isValid.values.reduce(0, +))")]
    + patterns.map {
      var string = AttributedString($0)

      guard let valid = isValid[$0] else { return string }

      string.foregroundColor = valid > 0 ? .green : .red

      return string
    }
  }
}

extension Day19ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day19.example
        case .puzzle: Inputs.Day19.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case checkPatterns

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .checkPatterns: "Check patterns"
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

extension Day19ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .checkPatterns, computation: checkPatterns)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .checkPatterns, computation: checkPatterns)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> ProblemData {
    let lines = input.lines

    let words = lines[0].split(separator: ", ").map { String($0) }
    let patterns = lines[1...].map { String($0) }

    return ProblemData(words: words, patterns: patterns)
  }

  private static func checkPatterns(_ input: ProblemData) -> ProblemData {
    var input = input
    input.checkPatterns()
    return input
  }
}
