---
title: Run a command
titleTemplate: :title | Quick start | Command
description: Learn how to run commands using Command in your Swift projects.
---

# Run a command

Once you've added `Command` as a dependency, import `Command` in your Swift file:

```swift
import Command
```

To run a command, create an instance of `CommandRunner`, which conforms the mockable protocol `CommandRunning`:

```swift
let commandRunner = CommandRunner()
```

And then run your first command, for `echo` which outputs the string passed as an argument:

```swift
let output = try await commandRunner.run(
      arguments: ["echo", "command is amazing"]
    ).concatenatedString()
```

> [!NOTE] EXECUTABLE LOOKUP
> When the executable is not an absolute path, the command runner will look for the executable in the system using the OS-specific search paths.

`run` returns a type `AsyncThrowingStream<CommandEvent, any Error>` which you can use to observe the output of the command. Since we are interested in the output of the command, we can use the function `concatenatedString()` defined on that type to get the output as a string.

By default, the comman will inherit the environment variables and the current working directory from the process that runs the command. You can customize them by using the arguments `environment` and `workingDirectory` of the `run` function.

```swift
let output = try await commandRunner.run(
      arguments: ["echo", "command is amazing"],
      environment: ["CUSTOM_ENV": "value"],
      workingDirectory: try AbsolutePath(validating: "/path/to/directory")
    ).concatenatedString()
```

> [!TIP] STATIC INTERFACE
> If you don't plan to mock the execution of commands, you can use the `Command` struct, which exposes the same interface as `CommandRunner` but as static functions:
> ```swift
> let output = Command.run(arguments: ["echo", "command is amazing"]).concatenatedString()
> ```