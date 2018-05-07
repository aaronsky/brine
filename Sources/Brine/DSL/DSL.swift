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

// MARK: Transform

public func transform<T: MatchTransformable>(_ type: T.Type) {
    World.shared.registerTransformableType(type)
}
