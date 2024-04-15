import ProjectDescription

let project = Project(name: "Process", targets: [
    .target(
        name: "Process",
        destinations: .macOS,
        product: .staticFramework,
        bundleId: "io.tuist.Process",
        deploymentTargets: .macOS("12.0"),
        sources: [
            "Sources/Process/**/*.swift",
        ],
        dependencies: [
            // .external(name: "Rainbow", condition: nil),
        ],
        settings: .settings(configurations: [
            .debug(name: .debug, settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"]),
            .release(name: .release, settings: [:]),
        ])
    ),
    .target(
        name: "ProcessTests",
        destinations: .macOS,
        product: .unitTests,
        bundleId: "io.tuist.ProcessTests",
        deploymentTargets: .macOS("12.0"),
        sources: [
            "Tests/ProcessTests/**/*.swift",
        ],
        dependencies: [
            .target(name: "Process"),
        ]
    ),
])
