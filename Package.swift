// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Command",
    platforms: [.macOS("12.0")],
    products: [
        .library(
            name: "Command",
            type: .static,
            targets: ["Command"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Command",
            dependencies: [
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
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
