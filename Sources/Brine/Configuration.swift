
import Foundation

public struct Configuration {
    public let featuresPath: URL
    
    public init() {
        let url = Bundle.currentTestBundle?.resourceURL?.appendingPathComponent("Features")
        // FIXME: Force unwrap
        self.init(featuresPath: url!)
    }
    
    public init(featuresPath: URL) {
        self.featuresPath = featuresPath
    }
}
