# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-08-11

- Update app layout known static assets ([#1](https://github.com/LostKobrakai/phoenix_vite/issues/1))
- Ship a small vite plugin
  - properly shut down when using npm ([#7](https://github.com/LostKobrakai/phoenix_vite/issues/7))
  - Make HMR with `:phoenix_live_reload`s `:notify` work ([#8](https://github.com/LostKobrakai/phoenix_vite/issues/8))
- Fixed mix task when igniter is not available
- Generate vite optimization config ([#9](https://github.com/LostKobrakai/phoenix_vite/issues/9))

## [0.2.2] - 2025-07-03

- Fix manifest references for production environment ([#4](https://github.com/LostKobrakai/phoenix_vite/pull/4))

## [0.2.1] - 2025-06-23

- Use `:bun` version 1.5 with the changes to `bun x`

## [0.2.0] - 2025-06-22

- Support local node/npm setups
- Split up igniter steps and add more tests

## [0.1.0] - 2025-06-22

### Added

- Components to handle vite assets both for the dev server as well as from a manifest
- Integration with bun elixir package
- Igniter installer

[unreleased]: https://github.com/LostKobrakai/phoenix_vite/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/LostKobrakai/phoenix_vite/releases/tag/v0.3.0
[0.2.2]: https://github.com/LostKobrakai/phoenix_vite/releases/tag/v0.2.2
[0.2.1]: https://github.com/LostKobrakai/phoenix_vite/releases/tag/v0.2.1
[0.2.0]: https://github.com/LostKobrakai/phoenix_vite/releases/tag/v0.2.0
[0.1.0]: https://github.com/LostKobrakai/phoenix_vite/releases/tag/v0.1.0
