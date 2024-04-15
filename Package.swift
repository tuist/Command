// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Process",
    platforms: [.macOS("12.0")],
    products: [
        .library(
            name: "Process",
            type: .static,
            targets: ["Process"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Process",
            dependencies: [
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "ProcessTests",
            dependencies: [
                "Process",
            ]
        ),
    ]
)
