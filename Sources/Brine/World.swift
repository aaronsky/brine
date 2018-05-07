import XCTest

@objc public class World: NSObject {
    public static let shared = World()

    public private(set) var application = XCUIApplication()

    private var steps: [StepDefinition] = []
    private var transformableTypes: [MatchTransformable.Type] = []

    override init() {
        super.init()
        PredefinedSteps.register()
        PredefinedHooks.register()
        PredefinedTransforms.register()
    }

    func registerStep(_ step: StepDefinition) {
        steps.append(step)
    }

    func registerTransformableType(_ type: MatchTransformable.Type) {
        transformableTypes.append(type)
    }

    func matchingSteps(for scenario: Scenario) -> [(Step, StepDefinition?)] {
        let stepsLIFO = steps.reversed()
        return scenario.steps.map { step in
            let stepDefinition = stepsLIFO.first { $0.matches(step.text) }
            return (step, stepDefinition)
        }
    }

    func arguments(for matches: [Regex.Match], in text: String) -> [Argument] {
        return zip(matches, transformableTypes).compactMap { zipped in
            let (match, type) = zipped
            return MatchArgument(match: match, type: type)
        }
    }
}
