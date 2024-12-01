import ArgumentParser

struct DayOne: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Day 1: Historian Hysteria"
  )

  private enum Errors: Error {
    case listSizesDoNotMatch
    case invalidEntry
  }

  @OptionGroup var options: SharedOptions

  mutating func run() throws {
    print("Day One")

    switch options.part {
      case .partOne: try partOne()
      case .partTwo: try partTwo()
    }
  }

  private func partOne() throws {
    print("Part One")

    let (listOne, listTwo) = try parseInput()
    let pairs = try makePairs(listOne: listOne, listTwo: listTwo)

    let distances = pairs.map {
      findDistance(entryOne: $0.0, entryTwo: $0.1)
    }

    let totalDistance = distances.reduce(0, +)

    print("Total distance: \(totalDistance)")
  }

  private func partTwo() throws {
    print("Part Two")

    let (listOne, listTwo) = try parseInput()
    let countsOne = countOccurrences(list: listOne)
    let countsTwo = countOccurrences(list: listTwo)

    var similarityScore = 0

    for (locationID, count) in countsOne {
      similarityScore += locationID * count * countsTwo[locationID, default: 0]
    }

    print("Similarity: \(similarityScore)")
  }

  private func parseInput() throws -> ([Int], [Int]) {
    let inputText = try String(contentsOf: options.pathToFile, encoding: .utf8)

    var listOne = [Int]()
    var listTwo = [Int]()

    for line in inputText.lines {
      let values = line.split(separator: " ")

      guard let valueOne = Int(values[0]) else {
        throw Errors.invalidEntry
      }

      guard let valueTwo = Int(values[1]) else {
        throw Errors.invalidEntry
      }

      listOne.append(valueOne)
      listTwo.append(valueTwo)
    }

    return (listOne, listTwo)
  }

  private func makePairs(listOne: [Int], listTwo: [Int]) throws -> [(Int, Int)] {
    guard listOne.count == listTwo.count else {
      throw Errors.listSizesDoNotMatch
    }

    let listOne = listOne.sorted()
    let listTwo = listTwo.sorted()

    return Array(zip(listOne, listTwo))
  }

  private func findDistance(entryOne: Int, entryTwo: Int) -> Int {
    abs(entryOne - entryTwo)
  }

  private func countOccurrences(list: [Int]) -> [Int: Int] {
    var counts = [Int: Int]()

    list.forEach {
      counts[$0, default: 0] += 1
    }

    return counts
  }
}
