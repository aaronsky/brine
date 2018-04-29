
import Gherkin

public struct Step {
    private let gh: GHStep
    
    public var text: String {
        return gh.text
    }
    
    init(from step: GHStep) {
        gh = step        
    }
}
