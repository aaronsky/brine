# Brine

[![Build Status](https://travis-ci.org/aaronsky/brine.svg?branch=master)](https://travis-ci.org/aaronsky/brine)

A BDD test suite using the Gherkin feature syntax and XCUITest

## Todo

- [x] Prototype
- [x] Xcode integration
- [x] Support for other scenario types (outlines, backgrounds)
- [ ] Match Cucumber feature specification more closely
    - [ ] Step results (logging should also be at parity)
    - [ ] Step arguments
        - [ ] Doc strings
        - [ ] Data Tables
    - [ ] Hooks
        - [ ] Before/After/Around Steps
        - [ ] Tagged hooks
    - [ ] Tags
        - [ ] Add to test/case names
        - [ ] Filter by tag
        - [ ] Tag inheritance
        - [ ] Tag expressions (for hooks and filtered runs)
- [ ] Link test failure to line in step **and** line in feature
- [ ] Improve logging
- [ ] "Code-only mode" – Brine without feature files
