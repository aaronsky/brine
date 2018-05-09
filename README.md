# Brine

[![Build Status](https://travis-ci.org/aaronsky/brine.svg?branch=master)](https://travis-ci.org/aaronsky/brine)

A BDD test suite using the Gherkin feature syntax and XCUITest

## Dependencies

* [Gherkin for Objective-C](https://github.com/cucumber/gherkin-objective-c) – using as-is
* [Cucumber Tag Expressions for Java](https://github.com/cucumber/cucumber/tree/master/tag-expressions/java) – ported from Java to Swift

## Todo

- [x] Prototype
- [x] Xcode integration
- [ ] Match Cucumber feature specification as closely as is reasonable
    - [x] Step results (logging should also be at parity)
    - [x] Other scenario types
        - [x] Scenario Outlines
        - [x] Backgrounds
    - [ ] Step arguments
        - [x] Step transforms
        - [x] Data Tables
        - [ ] Doc strings
    - [x] Hooks
        - [x] Before/After/Around Steps
        - [x] Tagged hooks
    - [ ] Tags
        - [x] Add to test/case names
        - [ ] Filter by tag
        - [x] Tag inheritance
        - [x] Tag expressions (for hooks and filtered runs)
- [ ] Link test failure to line in step **and** line in feature
- [ ] Package Manager support
    - [ ] Carthage
    - [ ] SPM
    - [ ] CocoaPods
- [ ] Improve logging
- [ ] "Code-only mode" – Brine without feature files
