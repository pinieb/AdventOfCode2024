// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation

@main
struct AOC24: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Wrapper utility for AoC 2024",
    subcommands: [
      DayOne.self,
      DayTwo.self,
    ],
    defaultSubcommand: DayOne.self
  )
}

struct SharedOptions: ParsableArguments {
  @Option(help: "Which subproblem to run.")
  var part: Subproblem

  @Option(
    help: "File containing problem input.",
    transform: URL.init(fileURLWithPath:)
  )
  var pathToFile: URL

  @Flag
  var verbose: Bool = false
}

enum Subproblem: String, ExpressibleByArgument {
    case partOne
    case partTwo
    case all
}
