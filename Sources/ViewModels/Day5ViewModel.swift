import Foundation
import Combine
import SwiftTUI


class Day5ViewModel: DayViewModel {
  let title = Day.five.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.example {
    didSet {
      resetState()
    }
  }

  @Published private(set) var selectedStep = StepID.loadData

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

extension Day5ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day5.example
        case .puzzle: Inputs.Day5.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case mapPageIndices
    case sumMiddlePageOfValidOrders

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .mapPageIndices: "Map page indices"
        case .sumMiddlePageOfValidOrders: "Sum middle page of valid orders"
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

// MARK: - Data Types

extension Day5ViewModel {
  struct PrintingData: DisplayableData {
    let rules: [(Int, Int)]
    let orders: [[Int]]

    var valid: [Bool?]

    init(
      rules: [(Int, Int)],
      orders: [[Int]]
    ) {
      self.rules = rules
      self.orders = orders

      self.valid = [Bool?](repeating: nil, count: orders.count)
    }

    var displayData: [AttributedString] {
      orders.enumerated()
        .map { index, order in
          var string = AttributedString("\(order)")

          if valid[index] == true {
            string.foregroundColor = .green
          }

          return string
        }
    }
  }
}

// MARK: - Pipelines

extension Day5ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipeline {
        StaticNode(id: StepID.loadData, value: input.inputValue)
        DynamicNode(id: StepID.parseData, computation: parseData)
        DynamicNode(id: StepID.mapPageIndices, computation: validateOrders)
        DynamicNode(id: StepID.sumMiddlePageOfValidOrders, computation: sumMiddlePageOfValidOrders)
      },
      .partTwo: DisplayablePipeline {
        StaticNode(id: StepID.loadData, value: input.inputValue)
      }
    ]
  }

  private static func parseData(_ input: String) -> PrintingData {
    let lines = input.split(separator: "\n", omittingEmptySubsequences: false)

    var rules = [(Int, Int)]()
    var i = 0
    while i < lines.count {
      guard lines[i] != "" else { 
        i += 1
        break
      }

      let line = lines[i]
      let pages = line
        .split(separator: "|")
        .compactMap { Int($0) }

      rules.append((pages[0], pages[1]))

      i += 1
    }

    var orders = [[Int]]()
    while i < lines.count {
      let line = lines[i]
      let pages = line
        .split(separator: ",")
        .compactMap { Int($0) }

      orders.append(pages)

      i += 1
    }

    return PrintingData(rules: rules, orders: orders)
  }

  private static func validateOrders(_ input: PrintingData) -> PrintingData {
    var data = input

    for (order, pages) in data.orders.enumerated() {
      var indexMap = [Int: Int]()

      pages.enumerated().forEach {         
        indexMap[$0.1] = $0.0
      }

      var isValid = true
      for rule in data.rules {
        guard 
          let index1 = indexMap[rule.0],
          let index2 = indexMap[rule.1]
        else { 
          continue
        }

        guard index1 < index2 else { 
          isValid = false
          break
        }
      }

      data.valid[order] = isValid
    }

    return data
  }

  static func sumMiddlePageOfValidOrders(_ input: PrintingData) -> Int {
    var sum = 0
    for (order, pages) in input.orders.enumerated() where input.valid[order] == true {
      sum += pages[(pages.count - 1) / 2]
    }
    return sum
  }
}
