import Foundation

public struct Configuration {
    public let featuresPath: URL?
    public let strict: Bool

    public init() {
        let url = Bundle.currentTestBundle?.resourceURL?.appendingPathComponent("Features")
        self.init(featuresPath: url)
    }

    public init(featuresPath: URL?, strict: Bool = false) {
        self.featuresPath = featuresPath
        self.strict = strict
    }

    func combine(into configuration: Configuration) -> Configuration {
        return Configuration(featuresPath: self.featuresPath ?? configuration.featuresPath, strict: strict || configuration.strict)
    }
}
