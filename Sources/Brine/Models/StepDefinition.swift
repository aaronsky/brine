import XCTest

public typealias BrineStepBlock = (StepContext) throws -> Void

public struct StepContext {
    public let application: XCUIApplication
    public let matches: [Regex.Match]
    public let arguments: [Argument]
    let world: World
    let testCase: XCTestCase

    public func pending() {
        world.setCurrentStepPending()
    }

    public func step(_ pattern: String) {
        // not yet implemented
    }

    public func step(_ pattern: Regex) {
        // not yet implemented
    }
}

struct StepDefinition: CustomStringConvertible {
    private let pattern: Regex
    private let handler: BrineStepBlock

    public var description: String {
        return pattern.description
    }

    init(_ pattern: Regex, handler: @escaping BrineStepBlock) {
        self.pattern = pattern
        self.handler = handler
    }

    func matches(_ string: String) -> Bool {
        return pattern.any(string)
    }

    func matches(for string: String) -> [Regex.Match] {
        return pattern.matches(for: string)
    }

    func execute(with matches: [Regex.Match], arguments: [Argument], testCase: XCTestCase, in world: World = World.shared) throws {
        let context = StepContext(application: world.application, matches: matches, arguments: arguments, world: world, testCase: testCase)
        try self.handler(context)
    }
}
