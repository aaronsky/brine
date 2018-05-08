import Gherkin

public struct Tag: CustomStringConvertible {
    private let gherkin: GHTag

    public var description: String {
        return gherkin.name
    }

    init(from tag: GHTag) {
        gherkin = tag
    }
}
