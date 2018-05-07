public typealias BrineScenarioHookBlock = (Scenario) -> Void
public typealias BrineAroundHookBlock = (Scenario, @autoclosure () -> Void) -> Void
public typealias BrineExitingHookBlock = () -> Void
public typealias BrineAfterConfigurationBlock = (Configuration) -> Void

class Hooks {
    var beforeEach: [ScenarioHook] = []
    var afterEach: [ScenarioHook] = []
    var around: [AroundHook] = []
    var exiting: [ExitingHook] = []
    var afterConfiguration: [AfterConfigurationHook] = []

    func before(_ scenario: Scenario) {
        beforeEach
            .filter({ $0.shouldRun(scenario) })
            .forEach { $0.run(scenario) }
    }

    func after(_ scenario: Scenario) {
        afterEach.reversed()
            .filter({ $0.shouldRun(scenario) })
            .forEach { $0.run(scenario) }
    }

    func around(_ scenario: Scenario, world: World) {
        if around.isEmpty {
            scenario.run(in: world)
            return
        }
        around
            .filter({ $0.shouldRun(scenario) })
            .forEach { $0.run(scenario, in: world) }
    }

    func exit() {
        exiting.forEach { $0.run() }
    }

    func afterConfiguration(_ configuration: Configuration) {
        afterConfiguration.forEach { $0.run(configuration) }
    }
}

private func evaluateTagExpression(_ tags: [String], scenario: Scenario) -> Bool {
    let scenarioTags = scenario.tags.map { $0.description }
    for expr in tags {
        let conditions = expr.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map { $0.hasPrefix("~") ? !scenarioTags.contains($0) : scenarioTags.contains($0) }
        guard Set(conditions).contains(false) else {
            return true
        }
    }
    return false
}

protocol TaggedHook {
    var tags: [String] { get }
    func shouldRun(_ scenario: Scenario) -> Bool
}

extension TaggedHook {
    func shouldRun(_ scenario: Scenario) -> Bool {
        if tags.isEmpty {
            return true
        }
        return evaluateTagExpression(tags, scenario: scenario)
    }
}

struct ScenarioHook: TaggedHook {
    let tags: [String]
    private let handler: BrineScenarioHookBlock

    init(tags: [String], handler: @escaping BrineScenarioHookBlock) {
        self.tags = tags
        self.handler = handler
    }

    func run(_ scenario: Scenario) {
        handler(scenario)
    }
}

struct AroundHook: TaggedHook {
    let tags: [String]
    private let handler: BrineAroundHookBlock

    init(tags: [String], handler: @escaping BrineAroundHookBlock) {
        self.tags = tags
        self.handler = handler
    }

    func run(_ scenario: Scenario, in world: World) {
        handler(scenario, scenario.run(in: world))
    }
}

struct ExitingHook {
    private let handler: BrineExitingHookBlock

    init(handler: @escaping BrineExitingHookBlock) {
        self.handler = handler
    }

    func run() {
        handler()
    }
}

struct AfterConfigurationHook {
    private let handler: BrineAfterConfigurationBlock

    init(handler: @escaping BrineAfterConfigurationBlock) {
        self.handler = handler
    }

    func run(_ configuration: Configuration) {
        handler(configuration)
    }
}
