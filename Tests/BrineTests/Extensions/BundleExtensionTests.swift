import XCTest
@testable import Brine

class BundleExtensionTests: XCTestCase {
    func testCurrentTestBundleAndModuleName() {
        let testBundle = Bundle.currentTestBundle
        let thisBundle = Bundle(for: type(of: self))
        XCTAssertNotNil(testBundle)
        XCTAssertEqual(testBundle?.moduleName, thisBundle.moduleName)
        XCTAssertEqual(testBundle?.bundleIdentifier, thisBundle.bundleIdentifier)
        XCTAssertEqual(testBundle?.bundlePath, thisBundle.bundlePath)
    }
}
