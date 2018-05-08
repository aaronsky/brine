import XCTest
import Gherkin

enum StepStatus {
    case waiting
    case success
    case undefined
    case pending
    case failed(Error)
    case skipped
    case ambiguous

    var groundsToSkip: Bool {
        switch self {
        case .undefined, .pending, .failed: return true
        default: return false
        }
    }
}

struct Step {
    let text: String
    var status: StepStatus = .waiting
    private let gherkin: GHStep

    var argument: Argument? {
        guard let table = gherkin.argument as? GHDataTable else {
            return nil
        }
        return table.toArgument()
    }

    init(from step: GHStep) {
        gherkin = step
        text = gherkin.text
    }

    init(copy step: Step, overridingText text: String? = nil) {
        gherkin = step.gherkin
        self.text = text ?? step.gherkin.text
    }

    mutating func run(_ testCase: XCTestCase, from scenario: Scenario, with definition: StepDefinition, in world: World) {
        let matches = definition.matches(for: text)

        var arguments: [Argument] = world.arguments(for: matches, in: text)
        if let argument = argument {
            arguments.append(argument)
        }

        do {
            try definition.execute(with: matches, arguments: arguments, testCase: testCase, in: world)
            status = .success
        } catch {
            status = .failed(error)
        }
    }
}

private extension GHDataTable {
    func toArgument() -> Argument? {
        let data: Data?
        if rows.first?.cells.count == 1 {
            let list = rows.flatMap { $0.cells.map { $0.value ?? "" } }
            data = try? JSONSerialization.data(withJSONObject: list)
        } else if let headers = rows.first {
            let table = Array(rows.dropFirst()).toTable(headers: headers)
            data = try? JSONSerialization.data(withJSONObject: table)
        } else {
            data = nil
        }
        guard let unwrappedData = data else {
            return nil
        }
        return CodableArgument(data: unwrappedData)
    }
}
