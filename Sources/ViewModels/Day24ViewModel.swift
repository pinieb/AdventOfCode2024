import Foundation
import Combine
import RegexBuilder
import SwiftTUI

class Day24ViewModel: DayViewModel {
  let title = Day.twentyFour.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.example1 {
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
    let input = Input.example1
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

fileprivate enum Gate {
  case or(_ lhs: String, _ rhs: String)
  case and(_ lhs: String, _ rhs: String)
  case xor(_ lhs: String, _ rhs: String)

  init?(operation: String, lhs: String, rhs: String) {
    switch operation {
      case "AND": self = .and(lhs, rhs)
      case "OR": self = .or(lhs, rhs)
      case "XOR": self = .xor(lhs, rhs)
      default: return nil
    }
  }

  var lhs: String {
    switch self {
      case .and(let lhs, _), 
        .or(let lhs, _), 
        .xor(let lhs, _):
        return lhs
    }
  }

  var rhs: String {
    switch self {
      case .and(_, let rhs), 
        .or(_, let rhs), 
        .xor(_, let rhs):
        return rhs
    }
  }

  var operation: String {
    switch self {
      case .and: "AND"
      case .or: "OR"
      case .xor: "XOR"
    }
  }

  var isAnd: Bool {
    switch self {
      case .and: true
      default: false
    }
  }

  var isOr: Bool {
    switch self {
      case .or: true
      default: false
    }
  }

  var isXor: Bool {
    switch self {
      case .xor: true
      default: false
    }
  }
}

fileprivate struct Circuit: DisplayableData {

  private let inputs: [String: Int]
  private let originalGates: [String: Gate]

  private(set) var solved: [String: Int]  
  private(set) var gates: [String: Gate]

  init(inputs: [String: Int], gates: [String: Gate]) {
    self.inputs = inputs
    self.originalGates = gates
    
    self.solved = inputs
    self.gates = gates
  }

  var displayData: [AttributedString] {
    gates.map { label, gate in
      let leftIsSolved = solved[gate.lhs] != nil
      var lhs = AttributedString(gate.lhs)
      lhs.foregroundColor = leftIsSolved ? .green : .red

      let rightIsSolved = solved[gate.rhs] != nil
      var rhs = AttributedString(gate.rhs)
      rhs.foregroundColor = rightIsSolved ? .green : .red

      let gateOperation = AttributedString(" \(gate.operation) ")
      let arrow = AttributedString(" -> ")

      let labelIsSolved = solved[label] != nil
      var label = AttributedString("\(label)\(labelIsSolved ? " (\(solved[label]!))" : "")")
      label.foregroundColor = labelIsSolved ? .green : .red

      return lhs + gateOperation + rhs + arrow + label
    }
  }

  mutating func powerOn() {
    for key in gates.keys {
      _ = solve(label: key, seen: Set<String>())
    }
  }

  func trace(label: String) -> [String] {
    if inputs[label] != nil { return [label] }
    guard let gate = gates[label] else { return [] }

    let lhs = trace(label: gate.lhs)
    let rhs = trace(label: gate.rhs)

    return lhs + rhs
  }

  private mutating func solve(label: String, seen: Set<String>) -> Int {
    if let output = solved[label] { return output }
    guard let gate = gates[label] else { return -1 }
    guard !seen.contains(label) else { return -1 }

    let lhs = solve(label: gate.lhs, seen: seen.union([label]))
    let rhs = solve(label: gate.rhs, seen: seen.union([label]))
    
    let result: Int
    switch gate {
      case .and: result = lhs & rhs
      case .or: result = lhs | rhs
      case .xor: result = lhs ^ rhs
    }

    solved[label] = result

    return result
  }

  mutating func reset() {
    solved = inputs
  }

  func findSuspiciousGates() -> [String] {
    var suspiciousWires = [String]()

    let outputs = gates.keys.filter { $0.hasPrefix("z") }
    for (output, gate) in gates {
      let hasXInput = gate.lhs.hasPrefix("x") || gate.rhs.hasPrefix("x")
      let hasYInput = gate.lhs.hasPrefix("y") || gate.rhs.hasPrefix("y")
      let hasStartingGateInput = gate.lhs.contains("00") || gate.rhs.contains("00")

      if hasXInput, hasYInput, !hasStartingGateInput {
        for (_, gate2) in gates where gate2.lhs == output || gate2.rhs == output {
          let hasDoubleAnd = gate.isAnd && gate2.isAnd
          let hasXorThenOr = gate.isXor && gate2.isOr

          if hasDoubleAnd || hasXorThenOr {
            suspiciousWires.append(output)
          }
        }
      }

      if !hasXInput, !hasYInput, !outputs.contains(output), gate.isXor {
        suspiciousWires.append(output)
      }

      if outputs.contains(output), output != "z\(outputs.count - 1)", !gate.isXor {
        suspiciousWires.append(output)
      }
    }

    return suspiciousWires.sorted()
  }

//   var suspiciousGates = new List<Gate>();
// var outputWires = wires.Values.Select(w => w).Where(w => w.name.StartsWith('z')).ToList();
// foreach (var gate in gates)
// {
//     // starting gates should be followed by OR if AND, and by AND if XOR, except for the first one
//     if ((gate.inputs[0].name.StartsWith('x') || gate.inputs[1].name.StartsWith('x')) &&
//         (gate.inputs[0].name.StartsWith('y') || gate.inputs[1].name.StartsWith('y')) &&
//         (!gate.inputs[0].name.Contains("00") && !gate.inputs[1].name.Contains("00")))
//         foreach (var secondGate in gates)
//             if (gate.output == secondGate.inputs[0] || gate.output == secondGate.inputs[1])
//                 if ((gate.op.Equals("AND") && secondGate.op.Equals("AND")) ||
//                     (gate.op.Equals("XOR") && secondGate.op.Equals("OR")))
//                     suspiciousGates.Add(gate);

//     // gates in the middle should not have XOR operators
//     if (!gate.inputs[0].name.StartsWith('x') && !gate.inputs[1].name.StartsWith('x') &&
//         !gate.inputs[0].name.StartsWith('y') && !gate.inputs[1].name.StartsWith('y') &&
//         !gate.output.name.StartsWith('z') && gate.op.Equals("XOR"))
//         suspiciousGates.Add(gate);

//     // gates at the end should always have XOR operators, except for the last one
//     if (outputWires.Contains(gate.output) && !gate.output.name.Equals($"z{outputWires.Count - 1}") && !gate.op.Equals("XOR"))
//         suspiciousGates.Add(gate);
// }
}

extension Day24ViewModel {
  enum Input: String, InputProtocol {
    case example1 = "Example 1"
    case example2 = "Example 2"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example1: Inputs.Day24.example1
        case .example2: Inputs.Day24.example2
        case .puzzle: Inputs.Day24.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case powerOn
    case computeZScore
    case traceWires
    case swapWiresAndRun
    case findSuspiciousWires

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .powerOn: "Power on"
        case .computeZScore: "Compute Z score"
        case .traceWires: "Trace wires"
        case .swapWiresAndRun: "Swap wires and run"
        case .findSuspiciousWires: "Find suspicious wires"
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

extension Day24ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .powerOn, computation: powerOn)
        .dynamicNode(id: .computeZScore, computation: computeZScore)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findSuspiciousWires, computation: findSuspiciousWires)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> Circuit {
    let label = Reference<String>()
    let inputValue = Reference<Int>()
    let inputPattern = Regex {
      Capture(as: label) {
        OneOrMore { 
          ChoiceOf {
            CharacterClass.word
            CharacterClass.digit
          }
        }
      } transform: { String($0) }
      ": "
      Capture(as: inputValue) {
        ChoiceOf {
          "0"
          "1"
        }
      } transform: { Int($0)! }
    }

    let inputs = input.matches(of: inputPattern)
      .reduce(into: [String: Int]()) { result, next in
        result[next[label]] = next[inputValue]
      }

    let gateLabel = Reference<String>()
    let gateLHS: Reference<String> = Reference<String>()
    let gateOperator = Reference<String>()
    let gateRHS = Reference<String>()
    let gatePattern = Regex {
      Capture(as: gateLHS) {
        OneOrMore { 
          ChoiceOf {
            CharacterClass.word
            CharacterClass.digit
          }
        }
      } transform: { String($0) }

      " "

      Capture(as: gateOperator) {
        ChoiceOf {
          "AND"
          "OR"
          "XOR"
        }
      } transform: { String($0) }

      " "

      Capture(as: gateRHS) {
        OneOrMore { 
          ChoiceOf {
            CharacterClass.word
            CharacterClass.digit
          }
        }
      } transform: { String($0) }

      " -> "

      Capture(as: gateLabel) {
        OneOrMore { 
          ChoiceOf {
            CharacterClass.word
            CharacterClass.digit
          }
        }
      } transform: { String($0) }
    }

    let gates = input.matches(of: gatePattern)
      .reduce(into: [String: Gate]()) { result, next in 
        result[next[gateLabel]] = Gate(
          operation: next[gateOperator], 
          lhs: next[gateLHS], 
          rhs: next[gateRHS]
        )
      }

    return Circuit(inputs: inputs, gates: gates)
  }

  private static func powerOn(_ input: Circuit) -> Circuit {
    var circuit = input

    circuit.powerOn()

    return circuit
  }

  private static func computeZScore(_ input: Circuit) -> Int {
    let bits = input.gates.keys
      .filter { $0.hasPrefix("z") }
      .sorted { $0 > $1 }
      .map { input.solved[$0]! }

    var output = 0
    
    for bit in bits {
      output = output << 1
      output += bit
    }

    return output
  }

  private static func traceWires(_ input: Circuit) -> [String] {
    input.gates.keys
      .filter { $0.hasPrefix("z") }
      .sorted { $0 > $1 }
      .map { ([$0] + input.trace(label: $0)).joined(separator: ", ") }
  }

  private static func swapWiresAndRun(_ input: Circuit) -> String {
    guard let valid = swap(gates: input.gates, alreadySwapped: Set(), swapsNeeded: 4) else {
      return "Not found"
    }

    return valid
      .sorted()
      .joined(separator: ",")
  }

  private static func swap(
    gates: [String: Gate],
    alreadySwapped: Set<String>, 
    swapsNeeded: Int
  ) -> Set<String>? {
    guard swapsNeeded > 0 else {
      return isFunctionalCircuit(gates: gates) ? alreadySwapped : nil
    }

    var gates = gates

    for key1 in gates.keys where !alreadySwapped.contains(key1) {
      for key2 in gates.keys where !alreadySwapped.contains(key2) {
        guard key1 != key2 else { continue }

        var alreadySwapped = alreadySwapped
        alreadySwapped.insert(key1)
        alreadySwapped.insert(key2)

        let temp = gates[key1]!
        gates[key1] = gates[key2]
        gates[key2] = temp

        if let validSwaps = swap(
          gates: gates, 
          alreadySwapped: alreadySwapped, 
          swapsNeeded: swapsNeeded - 1
        ) {
          return validSwaps
        }
      }
    }

    return nil
  }

  private static func isFunctionalCircuit(gates: [String: Gate]) -> Bool {
    guard let bits = 
      Int(
          gates.keys
            .filter { $0.hasPrefix("z") }
            .sorted { $0 > $1 }
            .first!
            .dropFirst()
      ) else {
        return false
      }

    let max = (1 << bits) - 2
    for _ in 0..<10 {
      let x = Int.random(in: 0...max)
      let y = Int.random(in: 0...max)

      let inputs = makeInputs(x: x, y: y, bits: bits)

      var circuit = Circuit(
        inputs: inputs, 
        gates: gates
      )

      circuit.powerOn()

      guard computeZScore(circuit) == x + y else { return false }
    }

    return true
  }

  private static func makeInputs(x: Int, y: Int, bits: Int) -> [String: Int] {
    var output = [String: Int]()

    var x = x
    var y = y
    for bit in 0..<bits {
      let bitString: String
      if bit < 10 {
        bitString = "0\(bit)"
      } else { 
        bitString = "\(bit)"
      }

      output["x\(bitString)"] = x & 1
      output["y\(bitString)"] = y & 1

      x = x >> 1
      y = y >> 1
    }

    return output
  }

  private static func findSuspiciousWires(_ input: Circuit) -> String {
    input.findSuspiciousGates().joined(separator: ",")
  }
}
