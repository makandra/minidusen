# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

### Breaking changes

### Compatible changes

## 1.0.1 2025-08-20

### Compatible changes

- Support filter aliases (#25). Thanks to @botandrose.

## 1.0.0 2025-07-31

### Breaking changes

- Add a `phrase` flag to tokens

## 0.11.2 2024-10-31

### Compatible changes

- Fix: Performance of queries using a negation ("-xxx") is improved by using an anti-join instead of a "NOT IN".

## 0.11.1 2024-08-22

### Compatible changes

- Fix: Use ActiveSupport.on_load for extending ActiveRecord

## 0.11.0 2024-03-18

### Breaking changes

- only parse strings with single colons as fields

## 0.10.1 2022-03-16

### Compatible changes

- Add Rails 7.0 and Ruby 3.0 to test matrix

## 0.10.0 2021-08-11

### Compatible changes

- Remove Rails 3.2 and Ruby < 2.5 from test matrix
- Add Rails 6.1 and Ruby 3.0 to test matrix

## 0.9.0 2019-06-12

### Compatible changes

- CHANGELOG to satisfy [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) format.
- Use Rails 5.2 for tests instead of Rails 5.0
- Added Ruby 2.5.3 to test matrix
- Added support for Rails 6 RC1

## 0.8.0 2017-08-21

### Added
- Filters are now run in the context of the filter instance, not the filter class. This allows using private methods or instance variables.
