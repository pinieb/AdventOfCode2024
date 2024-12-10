import Foundation
import Combine
import SwiftTUI
import Collections

class Day9ViewModel: DayViewModel {
  let title = Day.nine.rawValue

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

// MARK: - Data objects

extension Day9ViewModel {
  struct File: Identifiable, DisplayableData {
    let id: Int
    let size: Int

    var blocks: Set<Int>

    init(id: Int, size: Int, startingIndex: Int) {
      self.id = id
      self.size = size
      self.blocks = Set(startingIndex...(startingIndex + size - 1))
    }

    func checksum() -> Int {
      var sum = 0

      for index in blocks {
        sum += id * index
      }

      return sum
    }

    var displayData: [AttributedString] {
      var title = AttributedString("File \(id)")
      title.foregroundColor = .red

      var output = [
        title,
        AttributedString("Size: \(size)"),
        AttributedString("Blocks: \(blocks)")
      ]

      output.append(AttributedString(" "))

      return output
    }
  }

  struct Disk: DisplayableData {
    let usedSpace: Int
    let totalBlocks: Int

    private(set) var files: [File]

    init(files: [File]) {
      self.files = files
      self.usedSpace = files.map { $0.size }.reduce(0, +)

      self.totalBlocks = files
        .compactMap { $0.blocks.max() }
        .max()! + 1
    }

    func checksum() -> Int {
      files.map { $0.checksum() }.reduce(0, +)
    }

    mutating func fragment() {
      var diskBlocks = mapDiskMemory()

      var blocksToMove = diskBlocks.sorted {
        $0.key > $1.key
      }

      for i in 0..<totalBlocks {
        guard diskBlocks[i] == nil else { continue }

        guard !blocksToMove.isEmpty else { break }

        let moving = blocksToMove.removeFirst()
        guard moving.key > i else { break }

        diskBlocks[moving.key] = nil
        diskBlocks[i] = moving.value
      }

      updateFileLocations(diskMap: diskBlocks)
    }

    mutating func compress() {
      var diskBlocks = mapDiskMemory()

      let sortedFiles = files
        .sorted { $0.id > $1.id }

      for file in sortedFiles {
        for i in 0..<totalBlocks {
          guard i < file.blocks.min() ?? Int.min else { break }

          var wasFree = true
          let openStart = i
          for offset in 0..<file.size {
            guard diskBlocks[i + offset] == nil else { 
              wasFree = false
              break
             }
          }

          guard wasFree else { continue }

          file.blocks.forEach {
            diskBlocks[$0] = nil
          }

          for newBlock in openStart..<(openStart + file.size) {
            diskBlocks[newBlock] = file.id
          }

          break
        }
      }

      updateFileLocations(diskMap: diskBlocks)
    }

    private func mapDiskMemory() -> [Int: Int] {
      var diskBlocks = [Int: Int]()

      for file in files {
        for block in file.blocks {
          diskBlocks[block] = file.id
        }
      }

      return diskBlocks
    }

    private mutating func updateFileLocations(diskMap: [Int: Int]) {
      for i in 0..<files.count {
        let blocks = Set<Int>(
          diskMap
          .filter { $0.value == files[i].id }
          .map { $0.key }
        )

        files[i].blocks = blocks
      }
    }

    var displayData: [AttributedString] {
      [
        AttributedString("File count: \(files.count)"),
        AttributedString("Used space: \(usedSpace)"),
        AttributedString("Contiguous space: \(totalBlocks)"),
        AttributedString("Checksum: \(checksum())"),
        AttributedString(" ")
      ] 
      // + files.flatMap { $0.displayData }
    }
  }
}

extension Day9ViewModel {
  enum Input: String, InputProtocol {
    case example = "Example"
    case puzzle = "Puzzle"

    var inputValue: String {
      switch self {
        case .example: Inputs.Day9.example
        case .puzzle: Inputs.Day9.puzzle
      }
    }
  }

  enum StepID: Hashable, Equatable, CaseIterable, CustomStringConvertible {
    case loadData
    case parseData
    case fragmentFiles
    case compressDisk

    var description: String {
      switch self {
        case .loadData: "Load data"
        case .parseData: "Parse data"
        case .fragmentFiles: "Fragment files"
        case .compressDisk: "Compress disk"
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

extension Day9ViewModel {
  private static func makePipelines(input: Input) -> [Subproblem: DisplayablePipeline<StepID>] {
    [
      .partOne: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .fragmentFiles, computation: fragmentFiles)
        .build(),
      .partTwo: DisplayablePipelineBuilder<StepID, None>()
        .staticNode(id: .loadData, value: input.inputValue)
        .dynamicNode(id: .parseData, computation: parseData)
        .dynamicNode(id: .compressDisk, computation: compressDisk)
        .build()
    ]
  }

  private static func parseData(_ input: String) -> Disk {
    let chars = Array(input)
    let ints = chars.compactMap { Int(String($0)) }

    var files = [File]()
    var diskIndex = 0
    for i in 0..<ints.count {
      if i.isMultiple(of: 2) {
        files.append(File(id: i / 2, size: ints[i], startingIndex: diskIndex))
      }

      diskIndex += ints[i]
    }

    return Disk(files: files)
  }

  private static func fragmentFiles(_ input: Disk) -> Disk { 
    var disk = input

    disk.fragment()

    return disk
  }

  private static func compressDisk(_ input: Disk) -> Disk { 
    var disk = input

    disk.compress()

    return disk
  }
}
