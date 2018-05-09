import Foundation

extension World {
    // MARK: Steps

    public func given(_ pattern: String, block: @escaping BrineStepBlock) {
        given(Regex(pattern, options: [.ignoreCase]), block: block)
    }

    public func given(_ pattern: Regex, block: @escaping BrineStepBlock) {
        registerStep(pattern: pattern, block: block)
    }

    public func when(_ pattern: String, block: @escaping BrineStepBlock) {
        when(Regex(pattern, options: [.ignoreCase]), block: block)
    }

    public func when(_ pattern: Regex, block: @escaping BrineStepBlock) {
        registerStep(pattern: pattern, block: block)
    }

    public func then(_ pattern: String, block: @escaping BrineStepBlock) {
        then(Regex(pattern, options: [.ignoreCase]), block: block)
    }

    public func then(_ pattern: Regex, block: @escaping BrineStepBlock) {
        registerStep(pattern: pattern, block: block)
    }

    private func registerStep(pattern: Regex, block: @escaping BrineStepBlock) {
        let step = StepDefinition(pattern, handler: block)
        registerStep(step)
    }

    // MARK: Hooks

    public func before(_ tagExpression: String = "", block: @escaping BrineScenarioHookBlock) {
        let hook = ScenarioHook(tags: tagExpression, handler: block)
        registerBeforeHook(hook)
    }

    public func after(_ tagExpression: String = "", block: @escaping BrineScenarioHookBlock) {
        let hook = ScenarioHook(tags: tagExpression, handler: block)
        registerAfterHook(hook)
    }

    public func around(_ tagExpression: String = "", block: @escaping BrineAroundHookBlock) {
        let hook = AroundHook(tags: tagExpression, handler: block)
        registerAroundHook(hook)
    }

    public func onExit(block: @escaping BrineExitingHookBlock) {
        let hook = ExitingHook(handler: block)
        registerExitingHook(hook)
    }

    public func afterConfiguration(block: @escaping BrineAfterConfigurationBlock) {
        let hook = AfterConfigurationHook(handler: block)
        registerAfterConfigurationHook(hook)
    }

    // MARK: Transform

    public func transform<T: MatchTransformable>(_ type: T.Type) {
        registerTransformableType(type)
    }
}
