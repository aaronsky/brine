import Foundation

public func given(_ pattern: String, block: @escaping BrineStepBlock) {
    given(pattern: Regex(pattern), block: block)
}

public func given(pattern: Regex, block: @escaping BrineStepBlock) {
    registerStep(pattern: pattern, block: block)
}

public func when(_ pattern: String, block: @escaping BrineStepBlock) {
    when(pattern: Regex(pattern), block: block)
}

public func when(pattern: Regex, block: @escaping BrineStepBlock) {
    registerStep(pattern: pattern, block: block)
}

public func then(_ pattern: String, block: @escaping BrineStepBlock) {
    then(pattern: Regex(pattern), block: block)
}

public func then(pattern: Regex, block: @escaping BrineStepBlock) {
    registerStep(pattern: pattern, block: block)
}

private func registerStep(pattern: Regex, block: @escaping BrineStepBlock) {
    let step = StepDefinition(pattern: pattern, handler: block)
    World.shared.registerStep(step)
}
