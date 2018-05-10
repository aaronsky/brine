import XCTest
import Gherkin
import TagExpressions

@objc public class Brine: NSObject {
    var configuration: Configuration
    var finalizeConfig = false

    var features: [Feature] = []
    public var world: World

    public init(_ world: World? = nil) {
        self.configuration = Configuration()
        self.world = world ?? World.shared
    }

    public func configure(with configuration: Configuration) {
        configure(with: [configuration])
    }

    public func configure(with configurations: [Configuration]) {
        precondition(!finalizeConfig, "Attempted to alter configuration after it has been finalized")
        configuration = configurations.reduce(configuration) { $1.combine(into: $0) }
    }

    public func start() {
        finalizeConfig = true
        world.hooks.afterConfiguration(configuration)
        BrineTestCase.classDelegate = self
        loadFeatures()
    }

    func loadFeatures() {
        features = configuration.featuresPath
            .flatMap(getFeatureFilePathsRecursively)
            .flatMap { $0.compactMap(loadFeature) } ?? []
    }

    func getFeatureFilePathsRecursively(in path: URL) -> [URL] {
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        } catch {
            preconditionFailure("Error crawling for files in \(path.path): \(error)")
        }
        var features: [URL] = []
        for path in contents {
            if path.pathExtension == "feature" {
                features.append(path)
            } else if path.isDirectoryPath {
                features.append(contentsOf: getFeatureFilePathsRecursively(in: path))
            }
        }
        return features
    }

    func loadFeature(from path: URL) -> Feature? {
        let parser = GHParser()
        guard let result = parser.parse(path.path) else {
            return nil
        }
        let testClass: AnyClass? = BrineTestCase.createClass(for: result.feature)
        return Feature(from: result.feature, filePath: path, testClass: testClass)
    }
}

extension Brine: BrineTestCaseDelegate {
    public func feature(forFeatureClass class: AnyClass) -> Feature? {
        return features.first(where: { $0.testClass == `class` })
    }

    public func scenarioShouldBeTested(_ scenario: Scenario) -> Bool {
        let tags = scenario.tags.map { $0.description }
        let expr = configuration.tagExpression ?? configuration.tags.joined(separator: " or ")
        return (try? TagExpressionParser().parse(expr).evaluate(tags)) ?? true
    }
}
