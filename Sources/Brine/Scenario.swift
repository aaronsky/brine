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

@objcMembers
public class Scenario: NSObject {
    private let gherkin: GHScenarioDefinition

    public let name: String
    public let kind: ScenarioKind
    public let steps: [Step]
    public let tags: [Tag]
    public let examples: [Example]

    public override var description: String {
        return gherkin.desc
    }

    public init(from scenario: GHScenarioDefinition) {
        gherkin = scenario
        name = gherkin.name
        kind = ScenarioKind(scenario.keyword)
        steps = gherkin.steps.map(Step.init)
        tags = gherkin.tags.map(Tag.init)
        examples = (gherkin as? GHScenarioOutline)?.examples.map(Example.init) ?? []
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
        self.init(gherkin: scenario.gherkin, name: name, kind: .scenarioOutline, steps: steps, tags: scenario.tags)
    }

    private init(gherkin: GHScenarioDefinition, name: String = "", kind: ScenarioKind = .unknown, steps: [Step] = [], tags: [Tag] = [], examples: [Example] = []) {
        self.gherkin = gherkin
        self.name = name
        self.kind = kind
        self.steps = steps
        self.tags = tags
        self.examples = examples
    }

    func run(in world: World) {
        let stepDefs = world.matchingSteps(for: self)
        for (step, def) in stepDefs {
            guard let def = def else {
                XCTFail("Existing step definition does not exist for \"\(step.text)\"")
                return
            }
            step.run(from: self, with: def, in: world)
        }
    }

    private func exampleScenarioName(for example: Example, index: Int) -> String {
        let name = example.data[index].map { $0.value }
        return self.name.appendingFormat(" %@ Example %lu", name.joined(separator: "-"), index + 1)
    }
}
