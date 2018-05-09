import Foundation

// MARK: Steps

public func given(_ pattern: String, block: @escaping BrineStepBlock) {
    given(Regex(pattern, options: [.ignoreCase]), block: block)
}

public func given(_ pattern: Regex, block: @escaping BrineStepBlock) {
    registerStep(with: pattern, block: block)
}

public func when(_ pattern: String, block: @escaping BrineStepBlock) {
    when(Regex(pattern, options: [.ignoreCase]), block: block)
}

public func when(_ pattern: Regex, block: @escaping BrineStepBlock) {
    registerStep(with: pattern, block: block)
}

public func then(_ pattern: String, block: @escaping BrineStepBlock) {
    then(Regex(pattern, options: [.ignoreCase]), block: block)
}

public func then(_ pattern: Regex, block: @escaping BrineStepBlock) {
    registerStep(with: pattern, block: block)
}

private func registerStep(with pattern: Regex, block: @escaping BrineStepBlock) {
    let step = StepDefinition(pattern, handler: block)
    World.shared.registerStep(step)
}

// MARK: Hooks

public func before(_ tagExpression: String = "", block: @escaping BrineScenarioHookBlock) {
    let hook = ScenarioHook(tags: tagExpression, handler: block)
    World.shared.registerBeforeHook(hook)
}

public func after(_ tagExpression: String = "", block: @escaping BrineScenarioHookBlock) {
    let hook = ScenarioHook(tags: tagExpression, handler: block)
    World.shared.registerAfterHook(hook)
}

public func around(_ tagExpression: String = "", block: @escaping BrineAroundHookBlock) {
    let hook = AroundHook(tags: tagExpression, handler: block)
    World.shared.registerAroundHook(hook)
}

public func onExit(block: @escaping BrineExitingHookBlock) {
    let hook = ExitingHook(handler: block)
    World.shared.registerExitingHook(hook)
}

public func afterConfiguration(block: @escaping BrineAfterConfigurationBlock) {
    let hook = AfterConfigurationHook(handler: block)
    World.shared.registerAfterConfigurationHook(hook)
}

// MARK: Transform

public func transform<T: MatchTransformable>(_ type: T.Type) {
    World.shared.registerTransformableType(type)
}
