import ArgumentParser

struct DayTwo: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Day 2: Red-Nosed Reports"
  )

  private enum Errors: Error {
  }

  @OptionGroup var options: SharedOptions

  mutating func run() throws {
    print("Day Two")

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

    let reports = try parseInput()
    let safeReports = reports.filter { report in
      areSafe(levels: report.levels)
    }

    print("Safe reports: \(safeReports.count)")
  }

  private func partTwo() throws {
    print("================= Part Two =================")

    let reports = try parseInput()
    let safeReports = reports.filter { report in
      areSafe(levels: report.levels, maxUnsafeLevelsToSkip: 1) ||
      areSafe(levels: Array(report.levels[1...]))
    }

    print("Safe reports: \(safeReports.count)")
  }

  private func parseInput() throws -> [Report] {
    verbosePrint("Parsing input...")
    let inputText = try String(contentsOf: options.pathToFile, encoding: .utf8)

    let reportLevels = inputText.lines
      .map { line in
        return line
          .split(separator: " ")
          .compactMap { Int($0) }
      }

    verbosePrint("Parsed levels:")
    verbosePrint(reportLevels)

    let reports = reportLevels
      .map {levels in
        Report(levels: levels)
      }

    verbosePrint("Parsed reports")
    verbosePrint(reports, onNewLine: true)

    return reports
  }

  private func areSafe(levels: [Int], maxUnsafeLevelsToSkip: Int = 0) -> Bool {
    verbosePrint("Checking levels for safety...")
    verbosePrint(levels)
    
    guard levels.count > 1 else { 
      verbosePrint("Levels are SAFE because there is at most one level.")
      return true 
    }
  
    let safetyMode: SafetyMode = levels[0] < levels[1] ? .increasing : .decreasing
    var previousLevel = levels[0]
    var skippedLevels = 0
    for i in 1..<levels.count {
      let currentLevel = levels[i]
      
      if isStepSafe(
        safetyMode: safetyMode,
        previousLevel: previousLevel, 
        currentLevel: currentLevel
      ) {
        previousLevel = currentLevel
        continue
      }

      guard skippedLevels < maxUnsafeLevelsToSkip else {
        verbosePrint("Levels are UNSAFE because step is UNSAFE and no more levels can be skipped.") 
        return false 
      }

      skippedLevels += 1
    }

    return true
  }

  private func isStepSafe(
    safetyMode: SafetyMode, 
    previousLevel: Int, 
    currentLevel: Int
    ) -> Bool {
      let diff = currentLevel - previousLevel
      verbosePrint("Checking safety of step from \(previousLevel) to \(currentLevel)...")
      verbosePrint("Step diff: \(diff)")

      if safetyMode == .increasing, diff < 0 {
        verbosePrint("Step is UNSAFE because it did not increase.")
        return false
      }

      if safetyMode == .decreasing, diff > 0 {
        verbosePrint("Step is UNSAFE because it did not decrease.")
        return false
      }

      guard (1...3).contains(abs(diff)) else { 
        verbosePrint("Step is UNSAFE because magnitude of the change is not in acceptable bounds.")
        return false
      }

      verbosePrint("Step is SAFE.")
      return true
  }

  // MARK: - Printing

  private func verbosePrint<T: CustomStringConvertible>(_ item: T) {
    guard options.verbose else { return }

    print(item)
  }

  private func verbosePrint<T: CustomStringConvertible>(_ list: [T], onNewLine: Bool = false) {
    guard options.verbose else { return }

    guard onNewLine else {
      print(list)
      return
    }

    for item in list {
      print(item)
    }
  }

  private func verbosePrint(_ list: [[Int]]) {
    guard options.verbose else { return }

    for item in list {
      verbosePrint(item)
    }
  }
}

private struct Report: CustomStringConvertible {
  let levels: [Int]

  init(levels: [Int]) {
    self.levels = levels
  }

  var description: String {
    """
    Report
      Levels: \(levels)
    """
  }
}

private enum SafetyMode: Equatable {
  case increasing
  case decreasing
}
