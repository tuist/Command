---
title: Command
titleTemplate: :title | Tuist
---

# Command

`Command` is a Swift Package with utilities to run system processes. It's a battle-tested package that underpins [Tuist](https://tuist.io)'s core functionality. It's compatible with Linux and macOS, and it's designed to be compliant with Swift's long-term plan for concurrency.

Given that `Foundation.Process` exists, you might be wondering why we created this package. There are several reasons:

- We integrate with [swift-log](https://github.com/apple/swift-log) to log debug information about the commands that are being run.
- We provide a more user-friendly API that makes it easier to run commands.
- We align the API with Swift's structured concurrency model, making it easier to run commands concurrently.
- We provide better error handling, making it easier to understand what went wrong when running a command.

## Add it to your project

### Swift Package Manager

You can edit your project's `Package.swift` and add `Command` as a dependency:

```swift
import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
    .package(url: "https://github.com/tuist/Command.git", .upToNextMajor(from: "0.2.0")) // [!code ++]
  ],
  targets: [
    .target(name: "MyProject", 
            dependencies: ["Command", .product(name: "Command", package: "Command")]), // [!code ++]
  ]
)
```

### Tuist

First, you'll have to add the `Command` package to your project's `Package.swift` file:

```swift
import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
    .package(url: "https://github.com/tuist/Command.git", .upToNextMajor(from: "0.2.0")) // [!code ++]
  ]
)
```

And then declare it as a dependency of one of your project's targets:

::: code-group
```swift [Project.swift]
import ProjectDescription

let project = Project(
    name: "App",
    organizationName: "tuist.io",
    targets: [
        .target(
            name: "App",
            destinations: [.iPhone],
            product: .app,
            bundleId: "io.tuist.app",
            deploymentTargets: .iOS("13.0"),
            infoPlist: .default,
            sources: ["Targets/App/Sources/**"],
            dependencies: [
                .external(name: "Command"),  // [!code ++]
            ]
        ),
    ]
)
```
:::

Make sure you run `tuist install` to fetch the dependencies before you generate the Xcode project.