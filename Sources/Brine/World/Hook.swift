// 
//  Hook.swift
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
import TagExpressions

public typealias BrineScenarioHookBlock = (Scenario) -> Void
public typealias BrineAroundHookBlock = (Scenario, @autoclosure () -> Void) -> Void
public typealias BrineExitingHookBlock = () -> Void
public typealias BrineAfterConfigurationBlock = (Configuration) -> Void

class Hooks {
    var beforeEach: [ScenarioHook] = []
    var afterEach: [ScenarioHook] = []
    var around: [AroundHook] = []
    var exiting: [ExitingHook] = []
    var afterConfiguration: [AfterConfigurationHook] = []

    func before(_ scenario: Scenario) {
        do {
            try beforeEach
                .filter({ try $0.shouldRun(scenario) })
                .forEach { $0.run(scenario) }
        } catch {
            fatalError("A problem occurred while processing beforeEach hooks: \(error)")
        }
    }

    func after(_ scenario: Scenario) {
        do {
            try afterEach.reversed()
                .filter({ try $0.shouldRun(scenario) })
                .forEach { $0.run(scenario) }
        } catch {
            fatalError("A problem occurred while processing beforeEach hooks: \(error)")
        }
    }

    func around(_ scenario: Scenario, block: @escaping () -> Void) {
        if around.isEmpty {
            block()
            return
        }
        do {
            try around
                .filter({ try $0.shouldRun(scenario) })
                .forEach { _ in block() }
        } catch {
            fatalError("A problem occurred while processing beforeEach hooks: \(error)")
        }
    }

    func exit() {
        exiting.forEach { $0.run() }
    }

    func afterConfiguration(_ configuration: Configuration) {
        afterConfiguration.forEach { $0.run(configuration) }
    }
}

protocol TaggedHook {
    var tags: String { get }
    func shouldRun(_ scenario: Scenario) throws -> Bool
}

extension TaggedHook {
    func shouldRun(_ scenario: Scenario) throws -> Bool {
        guard scenario.kind != .background else {
            return true
        }
        let parser = TagExpressionParser()
        let expression = try parser.parse(tags)
        return expression.evaluate(scenario.tags.map({ $0.description }))
    }
}

struct ScenarioHook: TaggedHook {
    let tags: String
    private let handler: BrineScenarioHookBlock

    init(tags: String, handler: @escaping BrineScenarioHookBlock) {
        self.tags = tags
        self.handler = handler
    }

    func run(_ scenario: Scenario) {
        handler(scenario)
    }
}

struct AroundHook: TaggedHook {
    let tags: String
    private let handler: BrineAroundHookBlock

    init(tags: String, handler: @escaping BrineAroundHookBlock) {
        self.tags = tags
        self.handler = handler
    }

    func run(_ scenario: Scenario, testCase: XCTestCase, in world: World) {
        handler(scenario, scenario.run(testCase, in: world))
    }
}

struct ExitingHook {
    private let handler: BrineExitingHookBlock

    init(handler: @escaping BrineExitingHookBlock) {
        self.handler = handler
    }

    func run() {
        handler()
    }
}

struct AfterConfigurationHook {
    private let handler: BrineAfterConfigurationBlock

    init(handler: @escaping BrineAfterConfigurationBlock) {
        self.handler = handler
    }

    func run(_ configuration: Configuration) {
        handler(configuration)
    }
}
