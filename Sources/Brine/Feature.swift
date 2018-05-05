import Gherkin
import ObjectiveC

@objcMembers
public class Feature: NSObject {
    private let gherkin: GHFeature
    let testClass: AnyClass?
    public let scenarios: [Scenario]
    public weak var background: Scenario?

    init(from feature: GHFeature, testClass: AnyClass? = nil) {
        gherkin = feature
        self.testClass = testClass
        scenarios = feature.children.map(Scenario.init)
    }
}
