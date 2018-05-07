import Gherkin

public struct Step {
    private let gherkin: GHStep

    public let text: String

    public var argument: Argument? {
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

    func run(from scenario: Scenario, with definition: StepDefinition, in world: World) {
        let matches = definition.matches(for: text)

        var arguments: [Argument] = world.arguments(for: matches, in: text)
        if let argument = argument {
            arguments.append(argument)
        }

        definition.execute(with: matches, arguments: arguments, in: world)
    }
}

private extension GHDataTable {
    func toArgument() -> Argument? {
        if rows.first?.cells.count == 1 {
            let list = rows.flatMap { $0.cells.map { $0.value ?? "" } }
            return ListArgument(list: list)
        } else if let headers = rows.first {
            let table = Array(rows.dropFirst()).toTable(headers: headers)
            return TableArgument(table: table)
        }
        return nil
    }
}
