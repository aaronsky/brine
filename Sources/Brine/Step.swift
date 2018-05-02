import Gherkin

public struct Step {
    private let gherkin: GHStep

    public var text: String {
        return gherkin.text
    }

    init(from step: GHStep) {
        gherkin = step
    }
}
