# Brine

[![Build Status](https://travis-ci.org/aaronsky/brine.svg?branch=master)](https://travis-ci.org/aaronsky/brine)

A [Cucumber](https://docs.cucumber.io/)-inspired BDD testing framework intended for use with Swift and Xcode UI Testing. Uses [Gherkin feature syntax](https://docs.cucumber.io/gherkin/reference/) for associating plain language to reusable step definitions.

## Features

* :computer: Integration with Xcode Test Navigator
* :iphone: Full support for Xcode UI Testing without additional runtime requirements
* :fast_forward: Designed for Gherkin features
* :cucumber: Parity with the [Cucumber API specification](https://docs.cucumber.io/cucumber/api/)
* :bookmark: Swift reimplementation of the [Cucumber Tag Expression](https://github.com/cucumber/cucumber/tree/master/tag-expressions) parser

### Coming Soon

* :package: Supports Carthage, Swift PM and CocoaPods!

## Install

Package manager support coming soon. Please stay tuned for the first tagged release!

## Usage

Write your feature file:

```gherkin
Feature: Test my great app with BDD

Scenario: Do the first test
    Given I am on the Home page
    When I tap the Add button
    Then nothing
```

Define your steps:

```swift
given("I am on the (.*) page") { context in
    let pageName = context.matches[0]
    XCTAssertEqual(pageName, "Home")
}

when("I tap the (.*) button") { context in
    context.pending()
}

then("nothing") { context in
    print("Do nothing")
}
```

Run your tests!

```swift
let brine = Brine()
brine.start()
```

## API

Coming soon

## Contributing

Hey, thanks for getting this far! If you'd like to contribute to Brine, please check out our [CONTRIBUTING](CONTRIBUTING.md) page before jumping in.

## Dependencies

* [Gherkin for Objective-C](https://github.com/cucumber/gherkin-objective-c) – using as-is
* [Cucumber Tag Expressions for Java](https://github.com/cucumber/cucumber/tree/master/tag-expressions/java) – ported from Java to Swift

## License

Apache © [Aaron Sky](https://skyaaron.com)
