// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation

@main
struct AOC24: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Wrapper utility for AoC 2024",
    subcommands: [
      Interactive.self,
      DayOne.self,
      DayTwo.self,
      DayThree.self
    ],
    defaultSubcommand: Interactive.self
  )
}

struct SharedOptions: ParsableArguments {
  @Option(help: "Which subproblem to run.")
  var part: SubproblemOption

  @Option(
    help: "File containing problem input.",
    transform: URL.init(fileURLWithPath:)
  )
  var pathToFile: URL

  @Flag
  var verbose: Bool = false
}

enum SubproblemOption: String, ExpressibleByArgument {
    case partOne
    case partTwo
    case all
}
