
import Gherkin

public struct Tag: CustomStringConvertible {
    private let gh: GHTag
    
    public var description: String {
        return gh.name
    }
    
    init(from tag: GHTag) {
        gh = tag
    }
}
