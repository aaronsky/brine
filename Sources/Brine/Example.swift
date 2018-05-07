import Foundation
import Gherkin

@objcMembers
public class Example: NSObject {
    private let gherkin: GHExamples
    public let data: [[String: String]]

    public override var description: String {
        return gherkin.desc
    }

    public init(from example: GHExamples) {
        gherkin = example
        data = gherkin.tableBody.toTable(headers: example.tableHeader)
    }
}

extension Array where Element == GHTableRow {
    func toTable(headers: GHTableRow) -> [[String: String]] {
        return map { row in
            return zip(headers.cells, row.cells)
                .reduce(into: [String: String]()) { accumulator, zip in
                    accumulator[zip.0.value] = zip.1.value
            }
        }
    }
}
