// 
//  BrineTestCase.swift
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
import ObjectiveC
import Gherkin

@objc public protocol BrineTestCaseDelegate {
    var world: World { get }
    func feature(forFeatureClass class: AnyClass) -> Feature?
    func scenarioShouldBeTested(_ scenario: Scenario) -> Bool
}

extension BrineTestCase {
    // MARK: XCTestCase overrides

    open override func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: Int, expected: Bool) {
        if let feature = BrineTestCase.classDelegate?.feature(forFeatureClass: type(of: self)),
            let scenario = feature.scenarios.first(where: { $0.running }),
            let lastRunningStep = scenario.steps.first(where: { $0.status == .running }) {
            let location = lastRunningStep.location
            super.recordFailure(withDescription: description, inFile: location.filePath.path, atLine: location.line, expected: expected)
        } else {
            super.recordFailure(withDescription: description, inFile: filePath, atLine: lineNumber, expected: expected)
        }
    }

    // MARK: Dynamic helpers

    class func createClass(for feature: GHFeature) -> AnyClass {
        let className = feature.name.pascalcased

        if let classNameCString = (className as NSString).utf8String,
            let featureClass = objc_allocateClassPair(BrineTestCase.self, classNameCString, 0) {
            objc_registerClassPair(featureClass)
            return featureClass
        } else if let featureClass = NSClassFromString(className) {
            objc_registerClassPair(featureClass)
            return featureClass
        }

        var mutFeatureClass: AnyClass?
        var mutClassName = className
        repeat {
            mutClassName = mutClassName.appendingFormat("%lu", 1 as CUnsignedLong)
            guard let classNameCString = (mutClassName as NSString).utf8String else {
                continue
            }
            mutFeatureClass = objc_allocateClassPair(BrineTestCase.self, classNameCString, 0)
        } while mutFeatureClass == nil

        guard let featureClass = mutFeatureClass else {
            fatalError("This should be impossible, but we are avoiding force unwrapping here anyway")
        }
        objc_registerClassPair(featureClass)
        return featureClass
    }

    @objc public class func addMethod(for selector: Selector) {
        guard let method = class_getInstanceMethod(BrineTestCase.self, #selector(BrineTestCase.executeScenario)) else {
            preconditionFailure("Couldn't get class method for executeScenario")
        }
        guard let types = ("v@:@:@" as NSString).utf8String else {
            preconditionFailure("Couldn't create types somehow")
        }
        class_addMethod(BrineTestCase.self, selector, method_getImplementation(method), types)
    }

    @objc private func executeScenario(_ scenario: Scenario, feature: Feature) {
        guard let world = BrineTestCase.classDelegate?.world else {
            XCTFail("Cannot run scenario \(scenario.name) without steps context. World is nil")
            return
        }
        world.hooks.before(scenario)
        feature.background?.run(self, in: world)
        world.hooks.around(scenario) {
            scenario.run(self, in: world)
        }
        world.hooks.after(scenario)
    }
}
