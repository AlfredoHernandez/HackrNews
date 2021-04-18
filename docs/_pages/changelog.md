---
layout: page
title: What's New
include_in_header: true
---

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

### `Latest`
## [0.4.0] - 2021-01-17

### Added 

- New Stories and Top Stories tabs
- New stories cell UI
- When user taps on a story, displays the URL content into a Safari navigation browser 

### Fixed

- Navigation bar with large title

---

## [0.3.0] - 2020-12-15

### Added

- A new scheme to create specific iOS components.
- A `HackrNewsFeedUIComposer` to create the `HackrNewsFeedViewController` which displays the new stories into a table view

---

## [0.2.0] - 2020-12-10

### Added

- This CHANGELOG file.
- A Network client based on `URLSession`
- A Generic `RemoteLoader`  to perform GET requests and decode retrieved data
- Presentation layer to display `Story` models
- Strings for `en` language in presentation layer