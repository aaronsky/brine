
import XCTest
import Brine

class Steps {
    static func registerSteps() {
        given("I am on the (.*) page") { context in
            print(context)
        }
        when("I tap the (.*) button") { context in
            print(context)
        }
        then("nothing") { context in
            print(context)
        }
    }
}
