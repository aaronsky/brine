import Gherkin

public struct Step {
    private let gherkin: GHStep

    public let text: String
    public var argument: GHStepArgument {
        return gherkin.argument
    }

    init(from step: GHStep) {
        gherkin = step
        text = gherkin.text
    }

    init(copy step: Step, overridingText text: String? = nil) {
        gherkin = step.gherkin
        self.text = text ?? step.gherkin.text
    }
}
