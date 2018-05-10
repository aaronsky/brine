import Foundation

public struct Configuration {
    public let featuresPath: URL?
    public let strict: Bool
    public let tags: [String]
    public let tagExpression: String?

    public init() {
        let url = Bundle.currentTestBundle?.resourceURL?.appendingPathComponent("Features")
        self.init(featuresPath: url)
    }

    public init(featuresPath: URL?, strict: Bool = false, tags: [String] = [], tagExpression: String? = nil) {
        self.featuresPath = featuresPath
        self.strict = strict
        self.tags = tags
        self.tagExpression = tagExpression
    }

    func combine(into configuration: Configuration) -> Configuration {
        return Configuration(featuresPath: featuresPath ?? configuration.featuresPath,
                             strict: strict || configuration.strict,
                             tags: tags + configuration.tags,
                             tagExpression: tagExpression ?? configuration.tagExpression)
    }
}
