import ProjectDescription

let project = Project(name: "Command", targets: [
    .target(
        name: "Command",
        destinations: .macOS,
        product: .staticFramework,
        bundleId: "io.tuist.Command",
        deploymentTargets: .macOS("13.0"),
        sources: [
            "Sources/Command/**/*.swift",
        ],
        dependencies: [
            .external(name: "Logging"),
            .external(name: "TSCBasic"),
            .external(name: "Path"),
        ],
        settings: .settings(base: ["SWIFT_STRICT_CONCURRENCY": "complete"],
                            configurations: [
                                .debug(name: .debug, settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"]),
                                .release(name: .release, settings: [:]),
                            ])
    ),
    .target(
        name: "CommandTests",
        destinations: .macOS,
        product: .unitTests,
        bundleId: "io.tuist.CommandTests",
        deploymentTargets: .macOS("13.0"),
        sources: [
            "Tests/CommandTests/**/*.swift",
        ],
        dependencies: [
            .target(name: "Command"),
        ]
    ),
])
