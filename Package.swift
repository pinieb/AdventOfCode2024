// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aoc24",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/rensbreur/SwiftTUI.git", branch: "main"),
        .package(
            url: "https://github.com/apple/swift-collections.git", 
            .upToNextMinor(from: "1.1.0") // or `.upToNextMajor
        ),
    ],
    targets: [
        .executableTarget(
            name: "aoc24",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "SwiftTUI", package: "SwiftTUI"),
            ]
        ),
    ]
)
