import Gherkin
import ObjectiveC

@objcMembers
public class Feature: NSObject {
    public let scenarios: [Scenario]
    public let location: Location
    public let tags: [Tag]
    public weak var background: Scenario?
    let testClass: AnyClass?
    private let gherkin: GHFeature

    init(from feature: GHFeature, filePath: URL, testClass: AnyClass? = nil) {
        gherkin = feature
        self.testClass = testClass
        location = Location(from: feature.location, filePath: filePath)
        tags = feature.tags.map(Tag.init)
        scenarios = feature.children.map { Scenario(from: $0, filePath: filePath) }
        super.init()
        scenarios.forEach { $0.parentTagsProvider = self }
    }
}

extension Feature: ParentTagsProvider {
    var parentTags: [Tag] {
        return tags
    }
}
