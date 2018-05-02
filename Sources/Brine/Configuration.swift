import Foundation

public struct Configuration {
    public let featuresPath: URL

    public init?() {
        guard let url = Bundle.currentTestBundle?.resourceURL?.appendingPathComponent("Features") else {
            return nil
        }
        self.init(featuresPath: url)
    }

    public init(featuresPath: URL) {
        self.featuresPath = featuresPath
    }
}
