// 
//  Brine.swift
// 
//  Copyright 2018 Aaron Sky
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 

import XCTest
import Gherkin
import TagExpressions

@objc public class Brine: NSObject {
    var configuration: Configuration
    var finalizeConfig = false

    var features: [Feature] = []
    /// The `World` instance used by Brine. Defaults to a singleton instance unless overridden at initialization
    public var world: World

    /**
     Initializes a new `Brine` instance for running BDD tests
     - parameter world: An instance of `World` to use instead of the default. Defaults to nil, which will use an internal instance.
    */
    public init(_ world: World? = nil) {
        self.configuration = Configuration()
        self.world = world ?? World.shared
        if self.world !== World.shared {
            World.shared.transferResponsibility(to: self.world)
        }
    }

    /**
     Configure the `Brine` instance with a single `Configuration`s
     - parameter configuration: A `Configuration` to apply
     */
    public func configure(with configuration: Configuration) {
        configure(with: [configuration])
    }

    /**
     Configure the `Brine` instance with a collection of `Configuration`s
     - parameter configurations: An `Array` of `Configuration`s to apply
    */
    public func configure(with configurations: [Configuration]) {
        precondition(!finalizeConfig, "Attempted to alter configuration after it has been finalized")
        configuration = configurations.reduce(configuration) { $1.combine(into: $0) }
    }

    /// Starts the Brine test run
    public func start() {
        finalizeConfig = true
        world.hooks.afterConfiguration(configuration)
        BrineTestCase.classDelegate = self
        loadFeatures()
    }

    /// Loads features as tests into XCTest using the configured features directory
    func loadFeatures() {
        features = configuration.featuresPath
            .flatMap(getFeatureFilePathsRecursively)
            .flatMap { $0.compactMap(loadFeature) } ?? []
    }

    /**
     Given a path to a directory, recursively locate all the `*.feature` files within its contents
     - parameter path: Path to a directory
     - returns: An array of `*.feature` file paths
    */
    func getFeatureFilePathsRecursively(in path: URL) -> [URL] {
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        } catch {
            preconditionFailure("Error crawling for files in \(path.path): \(error)")
        }
        var features: [URL] = []
        for path in contents {
            if path.pathExtension == "feature" {
                features.append(path)
            } else if path.isDirectoryPath {
                features.append(contentsOf: getFeatureFilePathsRecursively(in: path))
            }
        }
        return features
    }

    /**
     Loads a feature from a path and creates a test case class for it. If the Gherkin compiler cannot load the feature file, this method will return nil.
     - parameter path: Path to a `*.feature` file
     - returns: The loaded `Feature` object. Returns nil if the `*.feature` file cannot be loaded.
    */
    func loadFeature(from path: URL) -> Feature? {
        let parser = GHParser()
        guard let document = parser.parse(path.path),
            let feature = document.feature else {
            return nil
        }
        let testClass: AnyClass = BrineTestCase.createClass(for: feature.name)
        return Feature(from: feature, filePath: path, testClass: testClass)
    }
}

// MARK: BrineTestCaseDelegate

extension Brine: BrineTestCaseDelegate {
    /**
     Delegate method that returns the `Feature` instance for a given test class
     - parameter featureClass: A test class
     - returns: A `Feature` with a corresponding test class
    */
    public func feature(forFeatureClass featureClass: AnyClass) -> Feature? {
        return features.first(where: { $0.testClass == featureClass })
    }

    /**
     Delegate method that returns whether or not a given scenario should be tested, based on its tags.
     - parameter scenario: The scenario
     - returns: Whether or not the scenario should be tested
    */
    public func scenarioShouldBeTested(_ scenario: Scenario) -> Bool {
        let tags = scenario.tags.map { $0.description }
        let expr = configuration.tagExpression ?? configuration.tags.joined(separator: " or ")
        return (try? TagExpressionParser().parse(expr).evaluate(tags)) ?? true
    }
}
