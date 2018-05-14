// 
//  Scenario.swift
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

@objc public enum ScenarioKind: Int, CustomStringConvertible {
    case unknown
    case scenario
    case scenarioOutline
    case background

    public var description: String {
        switch self {
        case .scenario: return "scenario"
        case .scenarioOutline: return "scenario_outline"
        case .background: return "background"
        default: return "unknown"
        }
    }

    init(_ keyword: String) {
        switch keyword {
        case "Scenario": self = .scenario
        case "Scenario Outline": self = .scenarioOutline
        case "Background": self = .background
        default: self = .unknown
        }
    }
}

protocol ParentTagsProvider: class {
    var parentTags: [Tag] { get }
}

@objcMembers
public class Scenario: NSObject {
    public let name: String
    public let kind: ScenarioKind
    public let examples: [Example]
    public var running: Bool = false
    let location: Location
    let steps: [Step]
    private let scenarioTags: [Tag]
    private let gherkin: GHScenarioDefinition

    weak var parentTagsProvider: ParentTagsProvider?
    private var currentStepShouldBeMarkedPending: Bool = false
    private var additionalTestNameMetadata: String = ""

    public var tags: [Tag] {
        return (parentTagsProvider?.parentTags ?? []) + scenarioTags
    }

    public var testName: String {
        let tagNames = tags.map({ "tag\($0)" }).joined(separator: " ")
        let tagsSeparator = tagNames.isEmpty ? "" : " "
        let metadataSeparator = additionalTestNameMetadata.isEmpty ? "" : " "
        return "test_\(name.pascalcased)\(tagsSeparator)\(tagNames)\(metadataSeparator)\(additionalTestNameMetadata)".c99ExtendedIdentifier
    }

    public override var description: String {
        return gherkin.desc
    }

    init(from scenario: GHScenarioDefinition, filePath: URL) {
        gherkin = scenario
        name = gherkin.name
        location = Location(from: scenario.location, filePath: filePath)
        kind = ScenarioKind(scenario.keyword)
        steps = gherkin.steps.map { Step(from: $0, filePath: filePath) }
        scenarioTags = gherkin.tags.map(Tag.init)
        examples = (gherkin as? GHScenarioOutline)?.examples.map(Example.init) ?? []
        super.init()
        examples.forEach { $0.parentTagsProvider = self }
    }

    public convenience init(copy scenario: Scenario, asOutlineWithExample example: Example, index: Int) {
        let data = example.data[index]
        let steps: [Step] = scenario.steps.map { step in
            let text = data.reduce(into: step.text) { accumulator, pair in
                let placeholder = "<\(pair.key)>"
                accumulator = accumulator.replacingOccurrences(of: placeholder, with: pair.value)
            }
            return Step(copy: step, overridingText: text)
        }

        let additionalTestNameMetadata = "example \(index + 1) data \(data.map({ $0.value }).joined(separator: "-"))"
        self.init(gherkin: scenario.gherkin, name: scenario.name, location: scenario.location, kind: .scenarioOutline, steps: steps, tags: scenario.tags, additionalTestNameMetadata: additionalTestNameMetadata, parentTagsProvider: scenario.parentTagsProvider)
    }

    private init(gherkin: GHScenarioDefinition, name: String = "", location: Location, kind: ScenarioKind = .unknown, steps: [Step] = [], tags: [Tag] = [], examples: [Example] = [], additionalTestNameMetadata: String, parentTagsProvider: ParentTagsProvider? = nil) {
        self.gherkin = gherkin
        self.name = name
        self.location = location
        self.kind = kind
        self.steps = steps
        self.scenarioTags = tags
        self.examples = examples
        self.additionalTestNameMetadata = additionalTestNameMetadata
        self.parentTagsProvider = parentTagsProvider
        super.init()
        examples.forEach { $0.parentTagsProvider = self }
    }

    func run(_ testCase: XCTestCase, in world: World) {
        world.resetState()
        let stepsAndDefinitions = world.matchingSteps(for: self)
        world.setupStepHooks(with: self)
        running = true
        var lastStatus: StepStatus = .waiting
        for (step, definitions) in stepsAndDefinitions {
            if lastStatus.groundsToSkip {
                step.status = .skipped
            } else if definitions.count == 0 {
                step.status = .undefined
            } else if definitions.count > 1 {
                step.status = .ambiguous
                XCTFail("Step \"\(step.text)\" is ambiguous for definitions \"\(definitions.map { $0.description }.joined(separator: "\", \""))\"")
                return
            } else if let definition = definitions.first {
                step.run(testCase, from: self, with: definition, in: world)
            }
            lastStatus = currentStepShouldBeMarkedPending ? .pending : step.status
            currentStepShouldBeMarkedPending = false
        }
        running = false
    }

    func setCurrentStepPending() {
        self.currentStepShouldBeMarkedPending = true
    }
}

extension Scenario: ParentTagsProvider {
    var parentTags: [Tag] {
        return tags
    }
}
