import Foundation

public struct Configuration {
    public let featuresPath: URL?

    public init() {
        let url = Bundle.currentTestBundle?.resourceURL?.appendingPathComponent("Features")
        self.init(featuresPath: url)
    }

    public init(featuresPath: URL?) {
        self.featuresPath = featuresPath
    }

    func combine(into configuration: Configuration) -> Configuration {
        return Configuration(featuresPath: self.featuresPath ?? configuration.featuresPath)
    }
}
