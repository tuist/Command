# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.14.12] - 2026-06-24
### Details
#### Chore
- Update dependency apple/swift-log to from: "1.14.0" by @renovate[bot] in [#301](https://github.com/tuist/command/pull/301)

## [0.14.11] - 2026-06-24
### Details
#### Chore
- Update dependency kolos65/mockable to from: "0.6.4" by @renovate[bot] in [#300](https://github.com/tuist/command/pull/300)

## [0.14.10] - 2026-06-10
### Details
#### Chore
- Update dependency apple/swift-log to from: "1.13.2" by @renovate[bot] in [#284](https://github.com/tuist/command/pull/284)

## [0.14.9] - 2026-06-08
### Details
#### Bug Fixes
- Bound concurrent subprocess launches to avoid fd exhaustion by @fortmarek in [#275](https://github.com/tuist/command/pull/275)

## [0.14.8] - 2026-06-02
### Details
#### Bug Fixes
- Don't require getcwd to succeed when launching subprocesses by @fortmarek in [#272](https://github.com/tuist/command/pull/272)

## [0.14.7] - 2026-05-28
### Details
#### Chore
- Update dependency apple/swift-log to from: "1.13.1" by @renovate[bot] in [#267](https://github.com/tuist/command/pull/267)

## [0.14.6] - 2026-05-22
### Details
#### Chore
- Update dependency apple/swift-log to from: "1.12.1" by @renovate[bot] in [#264](https://github.com/tuist/command/pull/264)

## [0.14.5] - 2026-05-20
### Details
#### Bug Fixes
- Propagate error instead of trapping when working directory cannot be resolved by @fortmarek in [#262](https://github.com/tuist/command/pull/262)

## [0.14.4] - 2026-05-08
### Details
#### Bug Fixes
- Replace blocking waitUntilExit with async terminationHandler to prevent thread starvation by @irena327 in [#249](https://github.com/tuist/command/pull/249)

## New Contributors
* @irena327 made their first contribution in [#249](https://github.com/tuist/command/pull/249)
## [0.14.3] - 2026-05-01
### Details
#### Chore
- Update dependency kolos65/mockable to from: "0.6.2" by @renovate[bot] in [#221](https://github.com/tuist/command/pull/221)

## [0.14.2] - 2026-04-30
### Details
#### Chore
- Update dependency apple/swift-log to from: "1.12.0" by @renovate[bot] in [#219](https://github.com/tuist/command/pull/219)

## [0.14.1] - 2026-04-28
### Details
#### Bug Fixes
- Surface stderr and conform CommandError to LocalizedError by @fortmarek in [#231](https://github.com/tuist/command/pull/231)

## [0.14.0] - 2026-03-02
### Details
#### Features
- Include the command in error descriptions by @fortmarek in [#229](https://github.com/tuist/command/pull/229)

## New Contributors
* @fortmarek made their first contribution
## [0.13.0] - 2025-02-20
### Details
#### Features
- Windows support by @pepicrft in [#181](https://github.com/tuist/command/pull/181)

## [0.12.2] - 2025-02-14
### Details
#### Miscellaneous Tasks
- Update dependencies with security vulnerabilities by @pepicrft in [#201](https://github.com/tuist/command/pull/201)

## [0.12.1] - 2025-01-29
### Details
#### Chore
- Update dependency kolos65/mockable to from: "0.3.0" by @renovate[bot] in [#187](https://github.com/tuist/command/pull/187)

## [0.12.0] - 2025-01-22
### Details
#### Features
- Log standard output and error messages through the logger by @pepicrft in [#165](https://github.com/tuist/command/pull/165)

## [0.11.19] - 2025-01-22
### Details
#### Bug Fixes
- Release note generation by @pepicrft in [#180](https://github.com/tuist/command/pull/180)

## [0.11.18] - 2025-01-22
### Details
#### Bug Fixes
- Data race running many processes concurrently by @danpalmer in [#167](https://github.com/tuist/command/pull/167)

#### Documentation
- Add danpalmer as a contributor for code by @allcontributors[bot] in [#177](https://github.com/tuist/command/pull/177)

## New Contributors
* @danpalmer made their first contribution in [#167](https://github.com/tuist/command/pull/167)
## [0.11.0] - 2024-12-30
### Details
#### Features
- Add AsyncThrowingStream piping and completion utilities by @pepicrft in [#156](https://github.com/tuist/command/pull/156)

## [0.10.0] - 2024-12-11
### Details
#### Features
- Default to inheriting the standard input from the current process by @pepicrft in [#146](https://github.com/tuist/command/pull/146)

## [0.9.0] - 2024-08-30
### Details
#### Features
- Add `Command.run` static API for convenience by @pepicrft in [#102](https://github.com/tuist/command/pull/102)

## [0.8.0] - 2024-08-20
### Details
#### Features
- Add Mockable to ease mocking dowstream by @pepicrft

## [0.7.3] - 2024-08-15
### Details
#### Bug Fixes
- LookupExecutable race condition by @AndrewBarba in [#87](https://github.com/tuist/command/pull/87)

## [0.7.0] - 2024-08-13
### Details
#### Features
- Improve the documentation by @pepicrft

## [0.6.0] - 2024-08-11
### Details
#### Features
- Not resolve executables that are already passed as absolute paths by @AndrewBarba in [#80](https://github.com/tuist/command/pull/80)

## New Contributors
* @AndrewBarba made their first contribution
## [0.5.7] - 2024-08-11
### Details
#### Documentation
- Update .all-contributorsrc [skip ci] by @allcontributors[bot]
- Update README.md [skip ci] by @allcontributors[bot]

## [0.5.0] - 2024-08-04
### Details
#### Features
- Configure renovatebot to use semantic commits when updating dependencies by @pepicrft

## [0.4.0] - 2024-08-04
### Details
#### Features
- Adjust the convention for the CHANGELOG.md to follow a mix of the GitHub and the keep-a-changelog conventions by @pepicrft

## [0.3.0] - 2024-08-04
### Details
#### Bug Fixes
- Broken release automation due to invalid git cliff command by @pepicrft
- Release process again by @pepicrft
- Release process by @pepicrft

#### Features
- Add spi.yml documentation for the Swift Package Index to add a link to our self-hosted documentation by @pepicrft

## [0.2.1] - 2024-08-04
### Details
#### Documentation
- Create .all-contributorsrc [skip ci] by @allcontributors[bot]
- Update README.md [skip ci] by @allcontributors[bot]

## New Contributors
* @renovate[bot] made their first contribution in [#68](https://github.com/tuist/command/pull/68)
* @allcontributors[bot] made their first contribution
* @natanrolnik made their first contribution
* @waltflanagan made their first contribution in [#22](https://github.com/tuist/command/pull/22)
## [0.1.0] - 2024-04-16
### Details
## New Contributors
* @pepicrft made their first contribution
[0.14.12]: https://github.com/tuist/command/compare/0.14.11..0.14.12
[0.14.11]: https://github.com/tuist/command/compare/0.14.10..0.14.11
[0.14.10]: https://github.com/tuist/command/compare/0.14.9..0.14.10
[0.14.9]: https://github.com/tuist/command/compare/0.14.8..0.14.9
[0.14.8]: https://github.com/tuist/command/compare/0.14.7..0.14.8
[0.14.7]: https://github.com/tuist/command/compare/0.14.6..0.14.7
[0.14.6]: https://github.com/tuist/command/compare/0.14.5..0.14.6
[0.14.5]: https://github.com/tuist/command/compare/0.14.4..0.14.5
[0.14.4]: https://github.com/tuist/command/compare/0.14.3..0.14.4
[0.14.3]: https://github.com/tuist/command/compare/0.14.2..0.14.3
[0.14.2]: https://github.com/tuist/command/compare/0.14.1..0.14.2
[0.14.1]: https://github.com/tuist/command/compare/0.14.0..0.14.1
[0.14.0]: https://github.com/tuist/command/compare/0.13.0..0.14.0
[0.13.0]: https://github.com/tuist/command/compare/0.12.2..0.13.0
[0.12.2]: https://github.com/tuist/command/compare/0.12.1..0.12.2
[0.12.1]: https://github.com/tuist/command/compare/0.12.0..0.12.1
[0.12.0]: https://github.com/tuist/command/compare/0.11.19..0.12.0
[0.11.19]: https://github.com/tuist/command/compare/0.11.18..0.11.19
[0.11.18]: https://github.com/tuist/command/compare/0.11.17..0.11.18
[0.11.0]: https://github.com/tuist/command/compare/0.10.5..0.11.0
[0.10.0]: https://github.com/tuist/command/compare/0.9.32..0.10.0
[0.9.0]: https://github.com/tuist/command/compare/0.8.0..0.9.0
[0.8.0]: https://github.com/tuist/command/compare/0.7.8..0.8.0
[0.7.3]: https://github.com/tuist/command/compare/0.7.2..0.7.3
[0.7.0]: https://github.com/tuist/command/compare/0.6.3..0.7.0
[0.6.0]: https://github.com/tuist/command/compare/0.5.7..0.6.0
[0.5.7]: https://github.com/tuist/command/compare/0.5.6..0.5.7
[0.5.0]: https://github.com/tuist/command/compare/0.4.0..0.5.0
[0.4.0]: https://github.com/tuist/command/compare/0.3.0..0.4.0
[0.3.0]: https://github.com/tuist/command/compare/0.2.1..0.3.0
[0.2.1]: https://github.com/tuist/command/compare/0.2.0..0.2.1

<!-- generated by git-cliff -->
