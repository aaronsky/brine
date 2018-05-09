import XCTest
@testable import Brine

enum SomeEnum: CaseIterable {
    case one
    case two
    case three

    static var allCases: [SomeEnum] {
        return [
            .one,
            .two,
            .three
        ]
    }
}

class EnumExtensionTests: XCTestCase {
    func testCaseIterable() {
        let mockCases: [SomeEnum] = [
            .one,
            .two,
            .three
        ]
        SomeEnum.allCases.forEach { XCTAssertTrue(mockCases.contains($0)) }
    }
}
