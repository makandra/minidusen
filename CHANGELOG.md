# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- CHANGELOG to satisfy [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) format.

## [0.8.0] 2017-08-21

### Added
- Filters are now run in the context of the filter instance, not the filter class. This allows using private methods or instance variables.
