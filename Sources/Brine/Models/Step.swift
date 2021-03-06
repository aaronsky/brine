// 
//  Step.swift
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

enum StepStatus {
    case waiting
    case running
    case success
    case undefined
    case pending
    case failed
    case skipped
    case ambiguous

    var groundsToSkip: Bool {
        switch self {
        case .undefined, .pending, .failed: return true
        default: return false
        }
    }
}

class Step {
    let text: String
    var status: StepStatus = .waiting
    let location: Location
    private let gherkin: GHStep

    var argument: Argument? {
        if let table = gherkin.argument as? GHDataTable {
            return CodableArgument(table)
        } else if let docString = gherkin.argument as? GHDocString {
            return StringArgument(docString)
        }
        return nil
    }

    init(from step: GHStep, filePath: URL) {
        gherkin = step
        text = gherkin.text
        location = Location(from: step.location, filePath: filePath)
    }

    init(copy step: Step, overridingText text: String? = nil) {
        gherkin = step.gherkin
        self.text = text ?? step.gherkin.text
        location = step.location
    }

    func run(_ testCase: XCTestCase, from scenario: Scenario, with definition: StepDefinition, in world: World) {
        let matches = definition.matches(for: text)

        var arguments = world.arguments(for: matches, in: text)
        if let argument = argument {
            arguments.append(argument)
        }
        status = .running
        do {
            try definition.execute(with: matches, arguments: arguments, testCase: testCase, in: world)
            status = .success
        } catch {
            status = .failed
        }
    }
}
