
import Gherkin
import ObjectiveC

public struct Feature {
    let gh: GHFeature
    let scenarios: [Scenario]
    
    init(from feature: GHFeature) {
        gh = feature
        scenarios = feature.children.map(Scenario.init)
    }
}
