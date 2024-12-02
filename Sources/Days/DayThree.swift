import ArgumentParser

struct DayThree: ParsableCommand, VerbosePrintable {
  static let configuration = CommandConfiguration(
    abstract: "Day 3: "
  )

  private enum Errors: Error {
  }

  @OptionGroup var options: SharedOptions

  mutating func run() throws {
    print("***************** Day Three *****************")

    switch options.part {
      case .partOne: try partOne()
      case .partTwo: try partTwo()
      case .all:
        try partOne()
        try partTwo()
    }
  }

  private func partOne() throws {
    print("================= Part One =================")
  }

  private func partTwo() throws {
    print("================= Part Two =================")
  }

  private func parseInput() throws {
    verbosePrint("Parsing input...")
    let inputText = try String(contentsOf: options.pathToFile, encoding: .utf8)
  }
}
