// 
//  World.swift
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

private class WorldHook {
    private weak var target: AnyObject?
    private let handler: (AnyObject) -> () -> Void

    init<U: AnyObject>(_ target: U, handler: @escaping (U) -> () -> Void) {
        self.target = target
        self.handler = { handler($0 as! U) }
    }

    func invoke() {
        guard let target = target else {
            return
        }
        handler(target)()
    }
}

@objc public class World: NSObject {
    static let shared = World()

    public var userInfo: [String: Any] = [:]
    private(set) var application = XCUIApplication()
    private(set) var hooks = Hooks()

    private var steps: [StepDefinition] = []
    private var transformableTypes: [MatchTransformable.Type] = []

    private var setPendingHook: WorldHook?

    override init() {
        super.init()
        PredefinedSteps.register()
        PredefinedHooks.register()
        PredefinedTransforms.register()
    }

    public subscript(_ key: String) -> Any? {
        return userInfo[key]
    }

    func resetState() {
        userInfo = [:]
        setPendingHook = nil

//        application.launch()
//        guard application.wait(for: .runningForeground, timeout: 0.5) else {
//            XCTFail("Application never launched")
//            return
//        }
    }

    func transferResponsibility(to world: World) {
        world.userInfo = userInfo
        world.application = application
        world.hooks = hooks
        world.steps = steps
        world.transformableTypes = transformableTypes
        world.setPendingHook = setPendingHook
    }

    func registerStep(_ step: StepDefinition) {
        steps.append(step)
    }

    func registerTransformableType(_ type: MatchTransformable.Type) {
        transformableTypes.append(type)
    }

    func registerBeforeHook(_ hook: ScenarioHook) {
        hooks.beforeEach.append(hook)
    }

    func registerAfterHook(_ hook: ScenarioHook) {
        hooks.afterEach.append(hook)
    }

    func registerAroundHook(_ hook: AroundHook) {
        hooks.around.append(hook)
    }

    func registerExitingHook(_ hook: ExitingHook) {
        hooks.exiting.append(hook)
    }

    func registerAfterConfigurationHook(_ hook: AfterConfigurationHook) {
        hooks.afterConfiguration.append(hook)
    }

    func matchingSteps(for scenario: Scenario) -> [(Step, [StepDefinition])] {
        let stepsLIFO = steps.reversed()
        return scenario.steps.map { step in
            let stepDefinition = stepsLIFO.filter { $0.matches(step.text) }
            return (step, stepDefinition)
        }
    }

    func arguments(for matches: [Regex.Match], in text: String) -> [Argument] {
        return zip(matches, transformableTypes).compactMap { zipped in
            let (match, type) = zipped
            return MatchArgument(match: match, as: type)
        }
    }

    func setupStepHooks(with scenario: Scenario) {
        setPendingHook = WorldHook(scenario, handler: Scenario.setCurrentStepPending)
    }

    func setCurrentStepPending() {
        setPendingHook?.invoke()
    }
}
