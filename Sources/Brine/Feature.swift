import Gherkin
import ObjectiveC

public struct Feature {
    private let gherkin: GHFeature
    let scenarios: [Scenario]

    init(from feature: GHFeature) {
        gherkin = feature
        scenarios = feature.children.map(Scenario.init)
    }
}
