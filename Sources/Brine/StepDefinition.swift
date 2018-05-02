import XCTest

public typealias BrineStepBlock = (StepContext) -> Void

public struct StepContext {
    public let matches: [Regex.Match]
    public let world: World
}

public struct StepDefinition {
    private let pattern: Regex
    private let handler: BrineStepBlock

    init(pattern: Regex, handler: @escaping BrineStepBlock) {
        self.pattern = pattern
        self.handler = handler
    }

    public func matches(_ string: String) -> Bool {
        return pattern.any(string)
    }

    public func matches(for string: String) -> [Regex.Match] {
        return pattern.matches(for: string)
    }

    public func execute(with matches: [Regex.Match], in world: World = World.shared) {
        let context = StepContext(matches: matches, world: world)
        self.handler(context)
    }
}
