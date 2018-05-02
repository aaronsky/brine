import Gherkin
import ObjectiveC

public struct Feature {
    private let gherkin: GHFeature
    let testClass: AnyClass?
    let scenarios: [Scenario]

    init(from feature: GHFeature, testClass: AnyClass? = nil) {
        gherkin = feature
        self.testClass = testClass
        scenarios = feature.children.map(Scenario.init)
    }
}
