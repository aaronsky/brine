import XCTest
import Brine

class Steps {
    static func registerSteps() {
        given("I am on the (.*) page") { context in
            print(context.arguments.last ?? "")
        }
        when("I tap the (.*) button") { context in
            print(context.matches)
        }
        then("nothing") { context in
            print(context.matches)
        }

        given("there are (.*) cucumbers") { context in
            print(context.matches)
        }
        when("I eat (.*) cucumbers") { context in
            print(context.matches)
        }
        then("I should have (\\d+) cucumbers") { context in
            guard let arg = context.arguments.first as? MatchArgument,
                let cucumbers = arg.get(as: Int.self) else {
                XCTFail("could not cucumber for shit")
                return
            }
            print(">>>", cucumbers)
        }

        given("the following users") { context in
            for arg in context.arguments {
                guard let argument = arg as? CodableArgument else {
                    continue
                }
                let table = argument.get([User].self)
                print(table)
            }
        }
        then("print these numbers") { context in
            for arg in context.arguments {
                guard let argument = arg as? CodableArgument else {
                    continue
                }
                let list = argument.get([String].self)
                print(list)
            }
        }

        transform(Int.self)
        before { scenario in
            print(scenario.tags)
        }
    }
}
