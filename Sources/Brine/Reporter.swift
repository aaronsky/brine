typealias TestResult = (testRun: XCTestRun, feature: Feature)

class Reporter {
    class func report(on results: [TestResult]) {
        print("Log report here")
    }
}
