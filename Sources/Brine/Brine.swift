
import Foundation
import Gherkin

public class Brine {
    var configurations: [Configuration] = []
    var finalizeConfig = false
    
    var features: [Feature] = []
    var world: World
    
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
        loadFeatures()
        executeFeatures()
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
        return Feature(from: result.feature)
    }
    
    func executeFeatures() {
        for feature in features {
            for scenario in feature.scenarios {
                scenario.run(in: world)
            }
        }
    }
    
    // MARK: Runtime methods
    
    @objc static func testInvocations() {
        
    }
}
