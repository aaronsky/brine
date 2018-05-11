// 
//  StepDefinition.swift
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

/// Closure type for all step definitions
public typealias BrineStepBlock = (StepContext) throws -> Void

/// The context model passed to all step definition handlers
public struct StepContext {
    /// A reference to the active XCUIApplication instance.
    /// It isn't required to activate it in code as it should
    /// already be launched and active by the time the step is running.
    public let application: XCUIApplication
    /// A list of all matches produced from matching the Gherkin
    /// step to the current step definition.
    public let matches: [Regex.Match]
    /// A list of all arguments produced from either associated
    /// data tables, doc strings, or step argument transforms
    /// present in the step.
    public let arguments: [Argument]
    /// Internal reference to the active `World` instance
    let world: World
    /// Internal reference to the active `XCTestCase` instance
    let testCase: XCTestCase

    /// Mark current step's `Step.status` as `StepStatus.pending` and skip all subsequent steps.
    /// Use in place of a `notYetImplemented` throw.
    public func pending() {
        world.setCurrentStepPending()
    }

    /// Call a step directly by pattern (not yet implemented)
    public func step(_ pattern: String) {
        // not yet implemented
    }

    /// Call a step directly by pattern (not yet implemented)
    public func step(_ pattern: Regex) {
        // not yet implemented
    }
}

struct StepDefinition: CustomStringConvertible {
    private let pattern: Regex
    private let handler: BrineStepBlock

    public var description: String {
        return pattern.description
    }

    init(_ pattern: Regex, handler: @escaping BrineStepBlock) {
        self.pattern = pattern
        self.handler = handler
    }

    func matches(_ string: String) -> Bool {
        return pattern.any(string)
    }

    func matches(for string: String) -> [Regex.Match] {
        return pattern.matches(for: string)
    }

    func execute(with matches: [Regex.Match], arguments: [Argument], testCase: XCTestCase, in world: World = World.shared) throws {
        let context = StepContext(application: world.application, matches: matches, arguments: arguments, world: world, testCase: testCase)
        try self.handler(context)
    }
}
