import Foundation
import XCTest
@testable import Brine

extension Int: MatchTransformable {
    public static var patterns = ["(-?\\d+)"]

    public static func transform(_ match: Regex.Match) -> Int? {
        guard let str = match[0]?.match else {
            return nil
        }
        return Int(str)
    }
}

class ArgumentTests: XCTestCase {
    func testMatchArgument() {
        let expected = 200
        let regex: Regex = "(-?\\d+) dogs sitting in a row"
        let expression = "200 dogs sitting in a row"
        let matches = regex.matches(for: expression)
        guard let match = matches.first else {
            XCTFail("No matches found for expression")
            return
        }
        let argument = MatchArgument(match: match, as: Int.self)
        guard let actual = argument?.get(as: Int.self) else {
            XCTFail("Could not get argument value using type")
            return
        }
        XCTAssertEqual(expected, actual)
    }

    func testMatchArgumentForNilTest() {
        let regex: Regex = "(.*) dogs sitting in a row"
        let expression = "Many dogs sitting in a row"
        let matches = regex.matches(for: expression)
        guard let match = matches.first else {
            XCTFail("No matches found for expression")
            return
        }
        let argument = MatchArgument(match: match, as: Int.self)
        XCTAssertNil(argument)
    }

    func testCodableArgument() {
        let expected = ["dogs": "rule"]
        guard let data = try? JSONSerialization.data(withJSONObject: expected) else {
            XCTFail("Cannot create data from dictionary of strings")
            return
        }
        let argument = CodableArgument(data: data)
        let actual = argument.get(type(of: expected))
        XCTAssertEqual(expected, actual)
    }

    func testNamedArguments() {
        let expected = ["dogs": "rule"]
        guard let data = try? JSONSerialization.data(withJSONObject: expected) else {
            XCTFail("Cannot create data from dictionary of strings")
            return
        }
        let arg1 = CodableArgument(data: data, name: "arg1")
        let arg2 = CodableArgument(data: data, name: "arg2")
        let arg3 = CodableArgument(data: data, name: "arg3")
        let arguments = [arg1, arg2, arg3]
        XCTAssertNotNil(arguments.named("arg1"), "arg1 was not found in arguments")
        XCTAssertNotNil(arguments.named("arg2"), "arg2 was not found in arguments")
        XCTAssertNotNil(arguments.named("arg3"), "arg3 was not found in arguments")
        XCTAssertNil(arguments.named("arg4"), "arg4 was found in arguments, which should not be the case")
    }
}
