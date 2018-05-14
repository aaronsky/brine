// 
//  DSL+World.swift
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

import Foundation

extension World {

    // MARK: Steps

    public func given(_ pattern: Regex, block: @escaping BrineStepBlock) {
        registerStep(pattern: pattern, block: block)
    }

    public func when(_ pattern: Regex, block: @escaping BrineStepBlock) {
        registerStep(pattern: pattern, block: block)
    }

    public func then(_ pattern: Regex, block: @escaping BrineStepBlock) {
        registerStep(pattern: pattern, block: block)
    }

    private func registerStep(pattern: Regex, block: @escaping BrineStepBlock) {
        let step = StepDefinition(pattern, handler: block)
        registerStep(step)
    }

    // MARK: Hooks

    public func before(_ tagExpression: String = "", block: @escaping BrineScenarioHookBlock) {
        let hook = ScenarioHook(tags: tagExpression, handler: block)
        registerBeforeHook(hook)
    }

    public func after(_ tagExpression: String = "", block: @escaping BrineScenarioHookBlock) {
        let hook = ScenarioHook(tags: tagExpression, handler: block)
        registerAfterHook(hook)
    }

    public func around(_ tagExpression: String = "", block: @escaping BrineAroundHookBlock) {
        let hook = AroundHook(tags: tagExpression, handler: block)
        registerAroundHook(hook)
    }

    public func onExit(block: @escaping BrineExitingHookBlock) {
        let hook = ExitingHook(handler: block)
        registerExitingHook(hook)
    }

    public func afterConfiguration(block: @escaping BrineAfterConfigurationBlock) {
        let hook = AfterConfigurationHook(handler: block)
        registerAfterConfigurationHook(hook)
    }

    // MARK: Transform

    public func transform<T: MatchTransformable>(_ type: T.Type) {
        registerTransformableType(type)
    }
}
