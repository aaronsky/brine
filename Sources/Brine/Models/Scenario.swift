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
    let steps: [Step]
    private let scenarioTags: [Tag]
    private let gherkin: GHScenarioDefinition

    weak var parentTagsProvider: ParentTagsProvider?
    private var currentStepShouldBeMarkedPending: Bool = false

    public var tags: [Tag] {
        return (parentTagsProvider?.parentTags ?? []) + scenarioTags
    }

    public override var description: String {
        return gherkin.desc
    }

    public init(from scenario: GHScenarioDefinition) {
        gherkin = scenario
        name = gherkin.name
        kind = ScenarioKind(scenario.keyword)
        steps = gherkin.steps.map(Step.init)
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
        let name = scenario.exampleScenarioName(for: example, index: index)
        self.init(gherkin: scenario.gherkin, name: name, kind: .scenarioOutline, steps: steps, tags: scenario.tags, parentTagsProvider: scenario.parentTagsProvider)
    }

    private init(gherkin: GHScenarioDefinition, name: String = "", kind: ScenarioKind = .unknown, steps: [Step] = [], tags: [Tag] = [], examples: [Example] = [], parentTagsProvider: ParentTagsProvider? = nil) {
        self.gherkin = gherkin
        self.name = name
        self.kind = kind
        self.steps = steps
        self.scenarioTags = tags
        self.examples = examples
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
        for (var step, definitions) in stepsAndDefinitions {
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

    private func exampleScenarioName(for example: Example, index: Int) -> String {
        let name = example.data[index].map { $0.value }
        return self.name.appendingFormat(" %@ Example %lu", name.joined(separator: "-"), index + 1)
    }
}

extension Scenario: ParentTagsProvider {
    var parentTags: [Tag] {
        return tags
    }
}