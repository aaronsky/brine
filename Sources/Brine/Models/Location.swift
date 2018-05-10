import Gherkin

public struct Location: CustomStringConvertible {
    private let gherkin: GHLocation
    public let filePath: URL

    public var line: Int {
        return Int(gherkin.line)
    }

    public var column: Int {
        return Int(gherkin.column)
    }

    public var description: String {
        return "\(filePath.lastPathComponent) +\(line):\(column)"
    }

    init(from gherkin: GHLocation, filePath: URL) {
        self.gherkin = gherkin
        self.filePath = filePath
    }
}
