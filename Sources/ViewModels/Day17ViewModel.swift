import Foundation
import Combine
import SwiftTUI
import RegexBuilder

class Day17ViewModel: DayViewModel {
  let title = Day.seventeen.rawValue

  @Published var selectedPart = Subproblem.partOne
  @Published var selectedInput = Input.exampleOne {
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
    let input = Input.exampleOne
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

fileprivate enum OperandType: Equatable {
  case combo
  case literal
  case none
}

fileprivate enum Instruction: Int, CustomStringConvertible {
  case adv
  case bxl
  case bst
  case jnz
  case bxc
  case out
  case bdv
  case cdv

  var description: String {
    switch self {
      case .adv: "adv"
      case .bxl: "bxl"
      case .bst: "bst"
      case .jnz: "jnz"
      case .bxc: "bxc"
      case .out: "out"
      case .bdv: "bdv"
      case .cdv: "cdv"
    }
  }

  var operandType: OperandType {
    switch self {
      case .adv: .combo
      case .bxl: .literal
      case .bst: .combo
      case .jnz: .literal
      case .bxc: .none
      case .out: .combo
      case .bdv: .combo
      case .cdv: .combo
    }
  }
}

fileprivate struct ThreeBitComputer: DisplayableData { 
  private(set) var instructionPointer = 0
  private(set) var output = [Int]()
  private(set) var history = [String]()
  
  var registers: [Int]
  private(set) var instructions: [Int]

  init(
    registerA: Int, 
    registerB: Int, 
    registerC: Int, 
    instructions: [Int]
  ) {
    self.registers = [registerA, registerB, registerC]
    self.instructions = instructions
  }

  var isComplete: Bool {
    instructionPointer < 0 || instructionPointer >= instructions.count
  }

  var displayData: [AttributedString] {
    [
      AttributedString("Register A: \(registers[0])"),
      AttributedString("Register B: \(registers[1])"),
      AttributedString("Register C: \(registers[2])"),
      AttributedString(" "),
      AttributedString("Program: \(instructions)"),
      AttributedString("Instruction pointer: \(instructionPointer)"),
      AttributedString(" "),
      AttributedString("Output: \(output.map { "\($0)" }.joined(separator: ",")) "),
      AttributedString(" "),
      AttributedString("History: \(history)"),
    ]
  }

  mutating func reset() {
    registers = [0, 0, 0]
    instructionPointer = 0
    output = []
    history = []
  }

  mutating func processInstruction() {
    guard !isComplete else { return }

    guard let instruction = Instruction(rawValue: instructions[instructionPointer]) else {
      return
    }

    let operand: Int
    switch instruction.operandType {
      case .combo:
        operand = makeComboOperand(instructions[instructionPointer + 1])
      case .literal:
        operand = instructions[instructionPointer + 1]
      case .none: 
        operand = 0
    }

    switch instruction {
      case .adv: divide(registerIndex: 0, operand: operand)
      case .bdv: divide(registerIndex: 1, operand: operand)
      case .cdv: divide(registerIndex: 2, operand: operand)
      case .bxl: bitwiseXOR(literal: operand)
      case .bst: mod8(operand: operand)
      case .jnz: jumpIfNotZero(target: operand)
      case .bxc: bitwiseXORCombo()
      case .out: output(operand: operand)
    }

    history.append("\(instruction) \(operand)")
  }

  private mutating func divide(registerIndex: Int, operand: Int) {
    let numerator = Double(registers[0])
    let denominator = pow(Double(2), Double(operand))

    let result = Int(numerator / denominator)

    registers[registerIndex] = result

    instructionPointer += 2
  }

  private mutating func bitwiseXOR(literal: Int) {
    registers[1] = registers[1] ^ literal

    instructionPointer += 2
  }

  private mutating func mod8(operand: Int) {
    registers[1] = operand % 8

    instructionPointer += 2
  }

  private mutating func jumpIfNotZero(target: Int) {
    guard registers[0] != 0 else { 
      instructionPointer += 2
      return
    }

    instructionPointer = target
  }

  private mutating func bitwiseXORCombo() {
    registers[1] = registers[1] ^ registers[2]

    instructionPointer += 2
  }

  private mutating func output(operand: Int) {
    output.append(operand % 8)

    instructionPointer += 2
  }

  private func makeComboOperand(_ input: Int) -> Int {
    switch input {
      case 0: 0
      case 1: 1
      case 2: 2
      case 3: 3
      case 4: registers[0]
      case 5: registers[1]
      case 6: registers[2]
      default: -1
    }
  }
}

extension Day17ViewModel {
  enum Input: String, InputProtocol {
    case exampleOne = "Example one"
    case exampleTwo = "Example two"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .exampleOne: Inputs.Day17.exampleOne
        case .exampleTwo: Inputs.Day17.exampleTwo
        case .puzzle: Inputs.Day17.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case processInstruction
    case findValidData
    case processAllInstructions

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .processInstruction: "Process instruction"
        case .findValidData: "Find valid data"
        case .processAllInstructions: "Process all instructions"
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

extension Day17ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .repeatableNode(id: .processInstruction, computation: processInstruction)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: StepID.loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .findValidData, computation: findValidData)
        .dynamicNode(id: .processAllInstructions, computation: processAllInstructions)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> ThreeBitComputer {
    let registerA = Reference<Int>()
    let registerB = Reference<Int>()
    let registerC = Reference<Int>()

    let instructions = Reference<[Int]>()
    
    let pattern = Regex {
      "Register A: "
      Capture(as: registerA) {
        OneOrMore { .digit }
      } transform: { Int($0)! }

      One(.newlineSequence)

      "Register B: "
      Capture(as: registerB) {
        OneOrMore { .digit }
      } transform: { Int($0)! }

      One(.newlineSequence)

      "Register C: "
      Capture(as: registerC) {
        OneOrMore { .digit }
      } transform: { Int($0)! }

      One(.newlineSequence)
      One(.newlineSequence)

      "Program: "
      Capture(as: instructions) {
        OneOrMore {
          .digit
          Optionally(",")
        }
      } transform: {
        $0.split(separator: ",")
          .map { Int($0)! }
      }
    }

    let match = input.firstMatch(of: pattern)!

    return ThreeBitComputer(
      registerA: match[registerA], 
      registerB: match[registerB], 
      registerC: match[registerC], 
      instructions: match[instructions]
    )
  }

  nonisolated(unsafe) private static var regA = 0

  private static func processInstruction(_ input: ThreeBitComputer) -> ThreeBitComputer {
    var computer = input
    
    computer.reset()
    computer.registers[0] = regA
    regA += 1

    while !computer.isComplete {
      computer.processInstruction()
    }

    return computer
  }

  private static func findValidData(_ input: ThreeBitComputer) -> ThreeBitComputer {
    var computer = input

    var a = 0
    for i in 0...computer.instructions.count {
      a *= 8
      
      for offset in 0...7 {
        computer.reset()
        computer.registers[0] = a + offset

        while !computer.isComplete {
          computer.processInstruction()
        }

        if computer.output.reversed() == computer.instructions[(computer.instructions.count - i)...].reversed() {
          a += offset
          break
        }
      }
    }

    computer.reset()
    computer.registers[0] = a

    return computer
  }

  private static func processAllInstructions(_ input: ThreeBitComputer) -> ThreeBitComputer {
    var computer = input

    while !computer.isComplete {
      computer.processInstruction()
    }

    return computer
  }
}
