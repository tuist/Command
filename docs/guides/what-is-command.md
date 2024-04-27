---
title: What is Command?
description: Run system processes in Swift
---

# What is Command?

`Command` is a Swift Package with utilities to run system processes. It's a battle-tested package that underpins [Tuist](https://tuist.io)'s core functionality. It's compatible with Linux and macOS, and it's designed to be compatible with Swift's long-term plan for concurrency.

The implementation was originally forked from the [`swift-tools-support-core`](https://github.com/apple/swift-tools-support-core) package, which was a foundation upon which the Swift Package Manager was built. But since they decided to [deprecate the package](https://github.com/apple/swift-tools-support-core?tab=readme-ov-file#%EF%B8%8F-this-package-is-deprecated), we decided to fork it and maintain it as a separate package.

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