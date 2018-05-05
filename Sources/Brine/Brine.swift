import Foundation
import Gherkin

@objc public class Brine: NSObject {
    var configurations: [Configuration] = []
    var finalizeConfig = false

    var features: [Feature] = []
    public var world: World

    public init(_ world: World = World.shared) {
        self.world = world
    }

    public func configure(with configuration: Configuration) {
        configure(with: [configuration])
    }

    public func configure(with configurations: [Configuration]) {
        precondition(!finalizeConfig, "Attempted to alter configuration after it has been finalized")
        self.configurations.append(contentsOf: configurations)
    }

    public func start(filterForTags tags: [String] = []) {
        finalizeConfig = true
        BrineTestCase.classDelegate = self
        loadFeatures()
//        executeFeatures()
    }

    func loadFeatures() {
        let featuresPaths = configurations.map { $0.featuresPath }
        features = featuresPaths.flatMap(getFeatureFilePathsRecursively)
            .compactMap(loadFeature)
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
        return Feature(from: result.feature, testClass: testClass)
    }

//    func executeFeatures() {
//        for feature in features {
//            for scenario in feature.scenarios {
//                scenario.run(in: world)
//            }
//        }
//    }
}

extension Brine: BrineTestCaseDelegate {
    public func feature(forFeatureClass class: AnyClass) -> Feature? {
        return features.first(where: { $0.testClass == `class` })
    }
}
