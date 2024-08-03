# Command
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

Command is a micro Swift Package that provides utilities for running system processes. We extracted it from Tuist to make it available for other projects that might need to run system processes.

## Motivation

Given that `Foundation.Process` exists, you might be wondering why we created this package. There are several reasons:

- We integrate with [swift-log](https://github.com/apple/swift-log) to log debug information about the commands that are being run.
- We provide a more user-friendly API that makes it easier to run commands.
- We align the API with Swift's structured concurrency model, making it easier to run commands concurrently.
- We provide better error handling, making it easier to understand what went wrong when running a command.

## Development

### Using Tuist

1. Clone the repository: `git clone https://github.com/tuist/Command.git`
2. Generate the project: `tuist generate`


### Using Swift Package Manager

1. Clone the repository: `git clone https://github.com/tuist/Command.git`
2. Open the `Package.swift` with Xcode

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="http://natanrolnik.me"><img src="https://avatars.githubusercontent.com/u/1164565?v=4?s=100" width="100px;" alt="Natan Rolnik"/><br /><sub><b>Natan Rolnik</b></sub></a><br /><a href="https://github.com/tuist/Command/commits?author=natanrolnik" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!