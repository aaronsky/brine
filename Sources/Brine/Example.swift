import Foundation
import Gherkin

@objcMembers
public class Example: NSObject {
    public let data: [[String: String]]
    private let exampleTags: [Tag]
    private let gherkin: GHExamples
    weak var parentTagsProvider: ParentTagsProvider?

    public override var description: String {
        return gherkin.desc
    }

    public var tags: [Tag] {
        return (parentTagsProvider?.parentTags ?? []) + exampleTags
    }

    public init(from example: GHExamples) {
        gherkin = example
        data = gherkin.tableBody.toTable(headers: example.tableHeader)
        exampleTags = gherkin.tags.map(Tag.init)
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
