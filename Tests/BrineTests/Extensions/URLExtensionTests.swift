import XCTest
@testable import Brine

class URLExtensionTests: XCTestCase {
    func testFileName() {
        guard let url = URL(string: "/Users/.conf") else {
            XCTFail("Invalid URL for testing")
            return
        }
        let expected = ".conf"
        XCTAssertEqual(url.fileName, expected)
    }

    func testIsDirectoryPath() {
        guard let url1 = URL(string: "/Users/asky/"),
            let url2 = URL(string: "/Users/.conf") else {
                XCTFail("Invalid URLs for testing")
                return
        }
        XCTAssertTrue(url1.isDirectoryPath)
        XCTAssertFalse(url2.isDirectoryPath)
    }
}
