
import XCTest

public class World {
    public static let shared = World()
    
    public private(set) var application = XCUIApplication()
    
    private var steps: [StepDefinition] = []
    
    init() {
        PredefinedSteps.register()
    }
    
    func registerStep(_ step: StepDefinition) {
        steps.append(step)
    }
    
    func matchingSteps(for scenario: Scenario) -> [(Step, StepDefinition?)] {
        let stepsLIFO = steps.reversed()
        return scenario.steps.map { step in
            let stepDefinition = stepsLIFO.first { $0.matches(step.text) }
            return (step, stepDefinition)
        }
    }
}
