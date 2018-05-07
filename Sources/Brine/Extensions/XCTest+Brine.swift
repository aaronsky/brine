import XCTest

func XCTAssertConformance<T>(_ obj: Any, _ type: @autoclosure () -> T.Type, _ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertNotNil(obj as? T, message(), file: file, line: line)
}
