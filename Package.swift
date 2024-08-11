// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Command",
    platforms: [.macOS("13.0")],
    products: [
        .library(
            name: "Command",
            type: .static,
            targets: ["Command"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.2")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.6.1")),
    ],
    targets: [
        .target(
            name: "Command",
            dependencies: [
                .product(name: "Path", package: "Path"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "CommandTests",
            dependencies: [
                "Command",
            ]
        ),
    ]
)
