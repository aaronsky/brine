import Gherkin

public enum ScenarioKind {
    case unknown
    case scenario
    case scenarioOutline
    case background

    init(_ keyword: String) {
        switch keyword {
        case "scenario": self = .scenario
        case "scenario_outline": self = .scenarioOutline
        case "background": self = .background
        default: self = .unknown
        }
    }
}

@objcMembers
public class Scenario: NSObject {
    private let gherkin: GHScenarioDefinition

    public let kind: ScenarioKind
    public let steps: [Step]
    public let tags: [Tag]

    public var name: String {
        return gherkin.name
    }
    public override var description: String {
        return gherkin.desc
    }

    public init(from scenario: GHScenarioDefinition) {
        gherkin = scenario
        kind = ScenarioKind(scenario.keyword)
        steps = gherkin.steps.map(Step.init)
        tags = gherkin.tags.map(Tag.init)
    }

    func run(in world: World) {
        let stepDefs = world.matchingSteps(for: self)
        for (step, def) in stepDefs {
            guard let def = def else {
                XCTFail("Existing step definition does not exist for \"\(step.text)\"")
                return
            }
            let matches = def.matches(for: step.text)
            def.execute(with: matches, in: world)
        }
    }
}
