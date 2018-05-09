import XCTest
@testable import Brine

class NSStringExtensionTests: XCTestCase {
    func testC99ExtendedIdentifier() {
        let expected = "The_coolest_dog_in_town_named_Jim"
        let start = "The,coolest¶dog•in town,named¶Jim"
        XCTAssertEqual(start.c99ExtendedIdentifier, expected)
    }

    func testPascalCased() {
        let expected = "TheWorldIsNotYoursInAnyWorld"
        let start = "tHE WoRLd iS not yoURS IN AnY wORld"
        XCTAssertEqual(start.pascalcased, expected)
    }
}
