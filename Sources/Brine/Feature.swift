import Gherkin
import ObjectiveC

@objcMembers
public class Feature: NSObject {
    public let scenarios: [Scenario]
    public let tags: [Tag]
    public weak var background: Scenario?
    let testClass: AnyClass?
    private let gherkin: GHFeature

    init(from feature: GHFeature, testClass: AnyClass? = nil) {
        gherkin = feature
        self.testClass = testClass
        tags = feature.tags.map(Tag.init)
        scenarios = feature.children.map(Scenario.init)
        super.init()
        scenarios.forEach { $0.parentTagsProvider = self }
    }
}

extension Feature: ParentTagsProvider {
    var parentTags: [Tag] {
        return tags
    }
}
