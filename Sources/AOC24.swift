// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser

@main
struct AOC24: ParsableCommand {
  @Option(name: .shortAndLong, help: "The day to run.")
  var day: Int

  mutating func run() {
    print("Hello, Advent of Code 2024!")
  }
}
