---
title: Write tests
titleTemplate: :title | Quick start | Command
description: Learn how to test business logic that depends on Command.
---

# Write tests

When writing unit tests, you might want to stub the execution of commands to avoid running them in your tests. To ease that, Command uses the [Mockable](https://github.com/Kolos65/Mockable) macro to provide a mock `MockCommandRunning` when the `MOCKING` Swift active compilation condition is set in your project.

Add `MockableTest` as a dependency of your project, and set the `MOCKING` Swift active compilation condition when the targets compile with the `Debug` configuration.

Then you can use the mocks and the utilities from `MockableTest` to stub the execution of commands in your tests:

```swift
import XCTest
import MockableTest
import Command

final class MySubjectTests: XCTestCase {
    
    func test_some_logic() async throws {
        // Given
        let commandRunner = MockCommandRunning()
        given(commandRunner)
            .run(arguments: .value(["xcodebuild", "-project", "/path/to/Project.xcodeproj", "build"]), environment: .any, workingDirectory: .any)
            .willReturn(AsyncThrowingStream<CommandEvent, any Error> { continuation in
                continuation.yield(.standardOutput([UInt8]("first\n".utf8)))
                continuation.yield(.standardOutput([UInt8]("second\n".utf8)))
                continuation.finish()
            })
        let subject = Subject(commandRunner: commandRunner)
        
        // When
        let got = subject.run()

        // Then
        // ...expectations        
    }
}
```