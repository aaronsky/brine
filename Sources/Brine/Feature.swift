import Gherkin
import ObjectiveC

@objc public class Feature: NSObject {
    private let gherkin: GHFeature
    let testClass: AnyClass?
    @objc public let scenarios: [Scenario]

    init(from feature: GHFeature, testClass: AnyClass? = nil) {
        gherkin = feature
        self.testClass = testClass
        scenarios = feature.children.map(Scenario.init)
    }
}
