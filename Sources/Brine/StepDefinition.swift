import XCTest

public typealias BrineStepBlock = (StepContext) -> Void

public struct StepContext {
    public let application: XCUIApplication
    public let matches: [Regex.Match]
    public let arguments: [Argument]
}

public struct StepDefinition {
    private let pattern: Regex
    private let handler: BrineStepBlock

    init(_ pattern: Regex, handler: @escaping BrineStepBlock) {
        self.pattern = pattern
        self.handler = handler
    }

    public func matches(_ string: String) -> Bool {
        return pattern.any(string)
    }

    public func matches(for string: String) -> [Regex.Match] {
        return pattern.matches(for: string)
    }

    public func execute(with matches: [Regex.Match], arguments: [Argument], in world: World = World.shared) {
        let context = StepContext(application: world.application, matches: matches, arguments: arguments)
        self.handler(context)
    }
}
