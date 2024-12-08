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
    case removeValidOrders
    case createGraph
    case buildReplacementOrders

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .mapPageIndices: "Map page indices"
        case .sumMiddlePageOfValidOrders: "Sum middle page of valid orders"
        case .removeValidOrders: "Remove valid orders"
        case .createGraph: "Create graph"
        case .buildReplacementOrders: "Build replacement orders"
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
    var orders: [[Int]]

    var edges = [Int: Set<Int>]()

    var valid: [[Int]: Bool]

    init(
      rules: [(Int, Int)],
      orders: [[Int]]
    ) {
      self.rules = rules
      self.orders = orders

      self.valid = [[Int]: Bool]()
    }

    var displayData: [AttributedString] {
      var output = [AttributedString]()

      if !edges.isEmpty { 
        output += [AttributedString("Rules graph")]

        output += edges
        .sorted{ $0.0 < $1.0 }
        .map {
          AttributedString("\($0), \($1)")
        }

        output += [AttributedString(" ")]
      }

      output += [AttributedString("Orders")]

      output += orders
        .map { order in
          var string = AttributedString("\(order)")

          if valid[order] == true {
            string.foregroundColor = .green
          }

          if valid[order] == false {
            string.foregroundColor = .red
          }

          return string
        }

        return output
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
        DynamicNode(id: StepID.parseData, computation: parseData)
        DynamicNode(id: StepID.mapPageIndices, computation: validateOrders)
        DynamicNode(id: StepID.removeValidOrders, computation: removeValidOrders)
        DynamicNode(id: StepID.createGraph, computation: createGraph)
        DynamicNode(id: StepID.buildReplacementOrders, computation: buildReplacementOrders)
        DynamicNode(id: StepID.sumMiddlePageOfValidOrders, computation: sumMiddlePageOfValidOrders)
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

    for pages in data.orders {
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

      data.valid[pages] = isValid
    }

    return data
  }

  static func sumMiddlePageOfValidOrders(_ input: PrintingData) -> Int {
    var sum = 0
    for pages in input.orders where input.valid[pages] == true {
      sum += pages[(pages.count - 1) / 2]
    }
    return sum
  }

    static func removeValidOrders(_ input: PrintingData) -> PrintingData {
    var data = input

    data.orders.removeAll { order in
      data.valid[order, default: false]
    }

    return data
  }

  static func createGraph(_ input: PrintingData) -> PrintingData {
    var data = input

    for rule in data.rules {
      data.edges[rule.1, default: Set<Int>()].insert(rule.0)
    }

    return data
  }

  static func buildReplacementOrders(_ input: PrintingData) -> PrintingData {
    var data = input

    for (order, pages) in data.orders.enumerated() {
      var newOrder = [Int]()
      var remainingPages = pages

      while !remainingPages.isEmpty {
        let candidatePage = remainingPages.removeFirst()

        var canPlace = true
        for page in remainingPages {
          if data.edges[candidatePage]?.contains(page) ?? false {
            canPlace = false
            break
          }
        }

        if canPlace {
          newOrder.append(candidatePage)
        } else {
          remainingPages.append(candidatePage)
        }
      }

      data.orders[order] = newOrder
      data.valid[newOrder] = true
    }

    return data
  }
}
