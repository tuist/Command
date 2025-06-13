// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(productDestinations: [
        "Path": .macOS,
        "Mockable": .macOS,
        "Logging": .macOS,
    ])
#endif

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
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.8")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.6.3")),
        .package(url: "https://github.com/Kolos65/Mockable", .upToNextMajor(from: "0.3.0")),
    ],
    targets: [
        .target(
            name: "Command",
            dependencies: [
                .product(name: "Path", package: "Path"),
                .product(name: "Logging", package: "swift-log"),
                .product(
                    name: "Mockable", package: "Mockable",
                    condition: .when(platforms: [.macOS, .linux, .windows])
                ),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "CommandTests",
            dependencies: [
                .product(
                    name: "Mockable", package: "Mockable",
                    condition: .when(platforms: [.macOS, .linux, .windows])
                ),
                "Command",
            ]
        ),
    ]
)
