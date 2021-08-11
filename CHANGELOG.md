# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

### Breaking changes

-

### Compatible changes


## 0.10.0 2021-08-11

### Breaking changes

-

### Compatible changes

- Remove Rails 3.2 and Ruby < 2.5 from test matrix
- Add Rails 6.1 and Ruby 3.0 to test matrix

## 0.9.0 2019-06-12

### Breaking changes

-

### Compatible changes

- CHANGELOG to satisfy [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) format.
- Use Rails 5.2 for tests instead of Rails 5.0
- Added Ruby 2.5.3 to test matrix
- Added support for Rails 6 RC1

## 0.8.0 2017-08-21

### Added
- Filters are now run in the context of the filter instance, not the filter class. This allows using private methods or instance variables.
